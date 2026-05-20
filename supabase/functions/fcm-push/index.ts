// Setup Deno Serve
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.43.1";
import { GoogleAuth } from "npm:google-auth-library@9.11.0";

Deno.serve(async (req) => {
  // CORS configuration
  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
      }
    });
  }

  try {
    const payload = await req.json();
    console.log('Webhook payload received:', JSON.stringify(payload));

    const record = payload.record;
    if (!record) {
      return new Response(JSON.stringify({ error: 'No record found in payload' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      });
    }

    const { sender_id, receiver_id, message, image_url } = record;

    if (!receiver_id || !sender_id) {
      return new Response(JSON.stringify({ error: 'Missing sender_id or receiver_id' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      });
    }

    // Initialize Supabase Client using service_role key to bypass RLS policies
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // Fetch receiver's fcm_token
    const { data: receiverData, error: receiverError } = await supabase
      .from('users')
      .select('fcm_token, name')
      .eq('id', receiver_id)
      .single();

    if (receiverError || !receiverData?.fcm_token) {
      console.log(`No FCM token found for receiver ID: ${receiver_id}. Error: ${receiverError?.message}`);
      return new Response(JSON.stringify({ message: 'Receiver has no FCM token. Notification skipped.' }), {
        status: 200,
        headers: { 'Content-Type': 'application/json' }
      });
    }

    const receiverFcmToken = receiverData.fcm_token;

    // Fetch sender's name
    const { data: senderData, error: senderError } = await supabase
      .from('users')
      .select('name')
      .eq('id', sender_id)
      .single();

    const senderName = senderData?.name || 'Seseorang';

    // Parse service account credentials from env
    const firebaseCredentialsJson = Deno.env.get('FIREBASE_SERVICE_ACCOUNT');
    if (!firebaseCredentialsJson) {
      throw new Error('FIREBASE_SERVICE_ACCOUNT environment variable is not set');
    }

    const credentials = JSON.parse(firebaseCredentialsJson);
    const projectId = credentials.project_id;

    // Generate OAuth2 access token for Google API
    const auth = new GoogleAuth({
      credentials,
      scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
    });
    const client = await auth.getClient();
    const tokenResponse = await client.getAccessToken();
    const accessToken = tokenResponse.token;

    if (!accessToken) {
      throw new Error('Failed to generate OAuth2 access token');
    }

    // Construct the FCM notification payload
    const notificationPayload = {
      message: {
        token: receiverFcmToken,
        notification: {
          title: senderName,
          body: image_url ? '📷 Mengirim gambar' : message,
        },
        data: {
          sender_id: sender_id,
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
        }
      }
    };

    // Send the notification to Firebase Cloud Messaging API v1
    const fcmUrl = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;
    const fcmResponse = await fetch(fcmUrl, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${accessToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(notificationPayload),
    });

    const fcmResult = await fcmResponse.json();
    console.log('FCM API response:', JSON.stringify(fcmResult));

    if (!fcmResponse.ok) {
      throw new Error(`FCM API returned status ${fcmResponse.status}: ${JSON.stringify(fcmResult)}`);
    }

    return new Response(JSON.stringify({ success: true, fcmResult }), {
      status: 200,
      headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' }
    });

  } catch (error) {
    console.error('Error processing notification:', error.message);
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' }
    });
  }
});

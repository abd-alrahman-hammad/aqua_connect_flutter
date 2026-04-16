from firebase_functions import https_fn, firestore_fn
from firebase_admin import initialize_app, firestore, messaging
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import random
import datetime

# تهيئة تطبيق فايربيس
initialize_app()

@https_fn.on_call()
def send_email_otp(req: https_fn.CallableRequest) -> any:
    # 1. استلام الإيميل واللغة من تطبيق فلاتر
    user_email = req.data.get("email")
    user_lang = req.data.get("lang", "ar") # افتراضياً عربي إذا ما انبعثت اللغة
    
    if not user_email:
        return {"success": False, "error": "الرجاء إدخال إيميل صالح"}
    
    # 2. توليد كود من 6 أرقام
    otp_code = str(random.randint(100000, 999999))
    
    # 3. تخزين الكود في Firestore
    db = firestore.client()
    expiration_time = datetime.datetime.now(datetime.timezone.utc) + datetime.timedelta(minutes=30)
    
    db.collection("otps").document(user_email).set({
        "otp": otp_code,
        "expiresAt": expiration_time
    })
    
    # ==========================================
    # 4. إعدادات الإيميل (عدل هاي البيانات)
    # ==========================================
    sender_email = "rayyanapp26@gmail.com" # حط إيميلك هون
    sender_password = "umbb wqoj vcep corn" # حط الباسوورد هون
    
    # تجهيز رسالة الإيميل
    msg = MIMEMultipart()
    msg['From'] = sender_email
    msg['To'] = user_email
    
    # 5. تحديد محتوى الرسالة بناءً على اللغة
    if user_lang == "en":
        msg['Subject'] = "Verification Code from Rayyan"
        body = f"Welcome to Rayyan!\n\nYour verification code is: {otp_code}\nThis code is valid for 1 minute."
    else:
        msg['Subject'] = "كود التحقق من Rayyan"
        body = f"أهلاً بك في Rayyan!\n\nكود التحقق الخاص بك هو: {otp_code}\nهذا الكود صالح لمدة دقيقة واحدة."
        
    msg.attach(MIMEText(body, 'plain', 'utf-8'))
    
    try:
        # إرسال الإيميل
        server = smtplib.SMTP('smtp.gmail.com', 587)
        server.starttls()
        server.login(sender_email, sender_password)
        server.sendmail(sender_email, user_email, msg.as_string())
        server.quit()
        
        return {"success": True, "message": "تم إرسال الكود بنجاح"}
    except Exception as e:
        return {"success": False, "error": str(e)}

@firestore_fn.on_document_created(document="system_alerts/{alertId}")
def send_push_notification(event: firestore_fn.Event[firestore_fn.DocumentSnapshot | None]) -> None:
    if event.data is None:
        return
        
    alert_data = event.data.to_dict()
    user_id = alert_data.get("user_id")
    title = alert_data.get("title", "New Alert")
    body = alert_data.get("body", "")

    if not user_id:
        print("No user_id found in alert document.")
        return

    # Fetch FCM Token for the user
    db = firestore.client()
    user_doc = db.collection("users").document(user_id).get()
    
    if not user_doc.exists:
        print(f"User {user_id} not found.")
        return
        
    user_data = user_doc.to_dict()
    fcm_token = user_data.get("fcmToken")
    
    if not fcm_token:
        print(f"User {user_id} does not have an FCM token.")
        return
        
    # Send DATA-ONLY FCM Message (bypasses Android System UI drop bugs)
    message = messaging.Message(
        data={
            "title": title,
            "body": body,
            "is_critical": "true"
        },
        android=messaging.AndroidConfig(
            priority='high',
        ),
        apns=messaging.APNSConfig(
            payload=messaging.APNSPayload(
                aps=messaging.Aps(content_available=True)
            ),
        ),
        token=fcm_token,
    )
    
    try:
        response = messaging.send(message)
        print(f"Successfully sent data message: {response}")
    except Exception as e:
        print(f"Error sending message: {e}")
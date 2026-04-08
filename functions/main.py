from firebase_functions import https_fn
from firebase_admin import initialize_app, firestore
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
    expiration_time = datetime.datetime.now(datetime.timezone.utc) + datetime.timedelta(minutes=5)
    
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
        body = f"Welcome to Rayyan!\n\nYour verification code is: {otp_code}\nThis code is valid for 5 minutes."
    else:
        msg['Subject'] = "كود التحقق من Rayyan"
        body = f"أهلاً بك في Rayyan!\n\nكود التحقق الخاص بك هو: {otp_code}\nهذا الكود صالح لمدة 5 دقائق."
        
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
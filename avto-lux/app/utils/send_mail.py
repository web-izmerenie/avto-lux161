# -*- coding: utf-8 -*-

def send_mail(msg=None, theme=None):
	
	import smtplib
	from app.configparser import config
	
	mailc = config('MAIL')
	from_addr = mailc['FROM_ADDRESS']
	to = mailc['MAIN_RECIPIENT']
	user = mailc['USER']
	pwd = mailc['PASS']
	
	smtpserver = smtplib.SMTP(
		mailc['SMTP_PROVIDER']['HOST'], mailc['SMTP_PROVIDER']['PORT'])
	smtpserver.ehlo()
	smtpserver.starttls()
	smtpserver.login(user, pwd)
	body = ''.join(
		"Content-Type: text/html; charset=utf-8\r\n" +
		("From: %s\r\n" % from_addr) +
		("To: %s\r\n" % to) +
		("Subject: %s\r\n" % theme) +
		"\r\n" +
		msg +
		"\r\n"
	)
	smtpserver.sendmail(user, to, body.encode('utf-8'))
	smtpserver.close()

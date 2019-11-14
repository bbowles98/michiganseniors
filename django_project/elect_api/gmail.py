import smtplib, ssl


def sendMail(recipient, msg):

	sender = 'electblockchainvoting@gmail.com'
	password = 'sugisugi123'

	server = smtplib.SMTP('smtp.gmail.com', 587)
	server.ehlo_or_helo_if_needed()
	server.starttls()
	server.ehlo()
	server.login(sender, password)
	server.sendmail(sender, recipient, msg)
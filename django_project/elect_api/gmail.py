import smtplib, ssl

sender = 'electblockchainvoting@gmail.com'
password = 'sugisugi123'

server = smtplib.SMTP('smtp.gmail.com', 587)
server.ehlo_or_helo_if_needed()
server.starttls()
server.ehlo()
server.login(sender, password)

def sendMail(recipient, msg):

	server.sendmail(sender, recipient, msg)
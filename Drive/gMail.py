import pickle
import os.path
from googleapiclient.discovery import build
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request

import webbrowser

from email.mime.text import MIMEText
import base64

SCOPES = ['https://www.googleapis.com/auth/gmail.compose']
EMAIL = 'danny@postelectricstudio.com'

def createMessage(name, link, to = " "):
    messageFile = open('email.html', 'r', encoding="utf-8")
    messageString = messageFile.read()

    messageString = messageString.replace("NAME", name)
    messageString = messageString.replace("LINK", link)

    print("")
    print(messageString)
    message = MIMEText(messageString, 'html')

    message['to'] = to
    message['from'] = EMAIL
    message['subject'] = 'File Link'
    rawMessage = base64.urlsafe_b64encode(message.as_string().encode("utf-8"))
    return { 'raw': rawMessage.decode("utf-8") }

def createDraftEmail(service, name, link):
    message = {'message': createMessage(name, link)}
    draft = service.users().drafts().create(userId=EMAIL, body=message).execute()
    print("Draft id: {}\nDraft message: {}".format(draft['id'], draft['message']))
    webbrowser.open("https://mail.google.com/mail/u/0/#drafts")
    return draft

def authoriseGmail():
    creds = None
    if os.path.exists('token.pickle'):
        with open('token.pickle', 'rb') as token:
            creds = pickle.load(token)
    # If there are no (valid) credentials available, let the user log in.
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file('client_secrets.json', SCOPES)
            creds = flow.run_local_server(port=0)
        # Save the credentials for the next run
        with open('token.pickle', 'wb') as token:
            pickle.dump(creds, token)

    mail = build('gmail', 'v1', credentials=creds)
    return mail

import os
import gMail
import gDrive
import sys

PATH = ""
NAME = ""
try:
    PATH = sys.argv[1]
except IndexError:
    raise Exception("You need to provide the path to the files to be sent, fanny")

try:
    NAME = sys.argv[2]
except IndexError:
    NAME = "NAME"
    pass

def main():
    setCWD()
    print('Authorising Google Drive...')
    drive = gDrive.authoriseGDrive()
    print('Authorising Google Mail...')
    mail = gMail.authoriseGmail()

    folderToShare = drive.CreateFile({'id' : gDrive.getFileIDFromPath(PATH, drive)})
    folderToShare.FetchMetadata()

    gDrive.enableSharing(folderToShare)
    link = gDrive.getShareableLink(folderToShare)

    gMail.createDraftEmail(mail, NAME, link)

def setCWD():
    absolutePathOfThisScript = os.path.abspath(__file__)
    directoryName = os.path.dirname(absolutePathOfThisScript)
    os.chdir(directoryName)

main()



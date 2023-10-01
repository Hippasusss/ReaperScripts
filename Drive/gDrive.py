from pydrive.auth import GoogleAuth
from pydrive.drive import GoogleDrive
import os

def authoriseGDrive():
    gauth = GoogleAuth()
    gauth.LocalWebserverAuth()
    drive = GoogleDrive(gauth)
    return drive

def getFileIDFromPath(filePath, drive):
    print("Fetching file ID...")

    pathList = filePath.split(os.sep)
    pathList = pathList[2:]

    fileID = 'root'
    for dirName in pathList:
        fileList = drive.ListFile({'q': "'{}' in parents and trashed=false".format(fileID)}).GetList()
        for file in fileList:
            if file['title'] == dirName:
                fileID = file['id']

    if fileID == 'root':
        raise Exception("the path you provided wasn't on GDrive, fanny")

    print("Export folder ID: {}".format(fileID))
    return fileID

def enableSharing(file, readWrite = False):
    print("Enabling Sharing...")
    readWrites = 'writer' if readWrite else 'reader'
    file.InsertPermission({'type' : 'anyone',
                           'role' : readWrites,})

def getShareableLink(fileOrFolder):
    link = fileOrFolder['alternateLink']
    print("Shareable link: {}".format(link))
    return link

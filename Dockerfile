######################################################
# Build-Time Arguments for the Docker Runtime Engine #
######################################################

ARG REPO=kwaziio/windows
ARG TAG

#############################################################
# Base Microsoft Windows Server Core Image w/ IIS Installed #
#############################################################

FROM ${REPO}:${TAG}

#############################################
# Copies Custom PowerShell Scripts to Image #
#############################################

COPY scripts C:\\Scripts

#########################################################
# Updates Execution Policy to Permit PowerShell Scripts #
#########################################################

RUN powershell -Command Set-ExecutionPolicy RemoteSigned -Scope LocalMachine -Force

#######################################################
# Installs Google Chrome via Custom PowerShell Script #
#######################################################

RUN powershell -File C:\\scripts\\Install-Chrome.ps1

################################################
# Installs NodeJS via Custom PowerShell Script #
################################################

RUN powershell -File C:\\scripts\\Install-Node.ps1

###########################################################
# Installs Google Lighthouse via Custom PowerShell Script #
###########################################################

RUN powershell -File C:\\scripts\\Install-Lighthouse.ps1

###########################################################
# Installs Puppeteer Support via Custom PowerShell Script #
###########################################################

RUN powershell -File C:\\scripts\\Install-Puppeteer.ps1

#################################################
# Updates Container Image Environment Variables #
#################################################

ENV NODE_PATH=C:\Users\ContainerAdministrator\AppData\Roaming\npm\node_modules

########################################################
# Updates Metadata Associated with the Generated Image #
########################################################

CMD [ "powershell.exe", "-File", "C:\\Scripts\\Execute-Lighthouse.ps1" ]

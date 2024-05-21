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

#######################################################
# Copies Fonts Available in Local Resources Directory #
#######################################################

COPY resources/*.ttf C:\\Fonts/

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

########################################################
# Updates Metadata Associated with the Generated Image #
########################################################

CMD [ "powershell.exe", "-File", "C:\\Scripts\\Execute-Lighthouse.ps1" ]

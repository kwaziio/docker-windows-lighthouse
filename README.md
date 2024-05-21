# Google Lighthouse for Windows

This project manages the creation of a Windows Docker Image pre-configured with Google Chrome and support for the Google Lighthouse CLI. It is created and maintained by [KWAZI](https://kwazi.io).

## Getting Started

This project leverages Windows container images. The only compliant way to build or operate these images is via a Windows host. Please review Microsoft's guidance regarding [usage restrictions](https://hub.docker.com/_/microsoft-windows-server/).

*NOTE: This project only supports Windows Server 2019 and Windows Server 2022.*

### Building w/ Windows 2022

Execute the following command to build this image using Microsoft Windows Server 2022:

```PowerShell
docker build --build-arg TAG=2022 -t windows-lighthouse:2022 .
```

### Building w/ Windows 2019

Execute the following command to build this image using Microsoft Windows 2019:

```PowerShell
docker build --build-arg TAG=2019 -t windows-lighthouse:2019 .
```

## Usage

This project is designed to support Windows DevOps environments; therefore, the examples provided within this document are designed for PowerShell.

### Basic Example

The following script will execute a basic Googe Lighthouse analysis against Google's main landing page:

```PowerShell
docker run --rm `
  -v .\reports:C:\Reports `
  -e URL=https://www.google.com `
  windows-lighthouse
```

The script above will generate an HTML report and store it at the mapped location for `$Output`.

### Basic Authentication Example

The following script will execute a Google Lighthouse analysis against Google's main landing page using URL-injected basic authentication credentials:

```PowerShell
docker run --rm `
  -v .\reports:C:\Reports `
  -e INJECT_BASIC_AUTH=1 `
  -e PASSWORD=Password123! `
  -e USERNAME=jdoe `
  -e URL=https://www.google.com `
  windows-lighthouse
```

This method for injecting basic authentication credentials is less than ideal, but at the time of writing Google Chrome doesn't support injecting headers for every request -- and neither does the Google Lighthouse CLI.

This method is most commonly helpful for scenarios where a Web Internet Information Services (IIS) application server is being targeted that has built-in user authentication at the server level. This pattern is common for intranet websites.

### Advanced Authentication Example

TODO

### Recognized Environment Variables

The following table of environment variables are supported by this Docker image:

Name | Description | Required (Y/N)
--- | --- | ---
CHROME_DEBUG_PORT | Port to Utilize for Chrome Remote Debugging | N
CHROME_DOWNLOAD_PATH | Path to Store Downloaded Chrome Installer | N
CHROME_DOWNLOAD_URL | URL Utilized to Download Chrome Installer | N
CHROME_EXECUTABLE | Path to Google Chrome Executable | N
CHROME_LAUNCH_INTERVAL | Seconds to Wait Between Chrome Liveness Tests | N
CHROME_LAUNCH_RETRIES | Maximum Number of Times to Run Chrome Liveness Tests | N
FILE | Path to Target URL Definition File | Y*
FONT_DIRECTORY | Directory Where Installable Fonts are Available | N
INJECT_BASIC_CREDS | `$true` or `1` if Basic Auth Credentials are Required | N
LIGHTHOUSE_EXECUTABLE | Path to Google Lighthouse CLI Executable | N
NODE_DOWNLOAD_PATH | Path to Store Downloaded NodeJS Installer | N
NODE_DOWNLOAD_URL | URL Utilized to Download NodeJS Installer | N
NODE_EXECUTABLE | Path to NodeJS Executable | N
NODE_RELEASE_URL | URL Utilized to Retrieve List of Node Versions | N
NPM_EXECUTABLE | Path to Node Package Manager (NPM) Executable | N
NPX_EXECUTABLE | Path to Node Package Executable (NPX) Executable | N
REPORTS_DIRECTORY | Directory to Store Generated Report Files | N
REPORTS_EXTENSION | File Extension to Utilize for Generated Reports | N
PASSWORD | Password to Utilize if Basic Auth is Enabled | N
URL | URL to Target for Google Lighthouse Analysis | Y*
URLs | List of URLs to Target for Google Lighthouse Analysis | Y*
USERNAME | Username to Utilize if Basic Auth is Enabled | N

Items denoted as "required" with an asterisk (Y*) are _conditionally_ required. At least one of the following variables MUST be provided:

* File
* URL
* URLs

> NOTE: Additional environment variables may be indirectly supported by the items that make this image work. For more information, see the documentation for relevant dependencies.

## Description

TODO: Provide Description

### Compatibility

This project creates Docker Images that are compatible with Windows Server 2022 and Windows Server 2019. The default base image is managed by [KWAZI](https://kwazi.io), which is based on the official Windows Server 2019 and Windows Server 2022 Docker Images managed by Microsoft.

*NOTE: Please review Microsoft's guidance regarding [usage restrictions](https://hub.docker.com/_/microsoft-windows-server/).*

### Google Chrome

The Google Lighthouse CLI relies on the remote debugging tools supported by Google Chrome.

For more information about the Google Chrome Chocolatey package, see the package's [official documentation](https://community.chocolatey.org/packages/GoogleChrome).

*NOTE: At the time of writing, maintainers have no intentions of replacing Google Chrome with another Chrome-based browser.*

### Node Package Manager (NPM)

The Google Lighthouse CLI is written for the NodeJS runtime and is distributed via Node Package Manager (NPM), the package management solution for NodeJS. This image includes both NPM and the NodeJS runtime.

For more information about the Google Lighthouse CLI, see the tool's [official documentation](https://github.com/GoogleChrome/lighthouse).

*NOTE: This project tracks the latest stable version of the Google Lighthouse CLI on available on NPM.*

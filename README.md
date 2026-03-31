# vpn_roadwarrior_configuration
Easy To Use
Cheap/Free
Flexibile
Vpn Solution

# Explanation
VPN On The Go,
Connect All Your Devices,
Invite Friends In Your World Wide Private Network
Share Your Work
Share Your Git Repositories
Make Your Windwos, Linux and MacOs Accessibile
Host Websites and Apps
Share Files Between The Devices And Develop And Deploy Projects Quickly
Device Via SSH and Broadcast Data Like Audio, Video and Other Packages.

## Server A
This is a low budget VPS from any provider of your choice.
I installed the newest FreeBSD image.
My Clients connect to this VPS via Wireguard.
  My Limited Android Phone Uses the Strongswan App, because builtin VPN support Is not supporting 
  Rooted Android Phones Can Use Wireguard instead.
  Windows Clients use the built-in

## Server B
This is low budget Workingstation for less than 60 Euro On Europerian Market.
It runs a freeBSD image
I configured it a Roadwarrior, that passes all my local devices to the connected VPN clients. This way my printer stays accessibile, even on holidays.
It forwards all my LAN Devices.

## Client
Google A14

## Rooting Google Pixel 3a
Google Pixel 3a
Setting Up Wireguard

## Windows Client
Everything works fine with the built-in VPN IKEv2 branch. A simple powershell fix needs to be run as admin, configuring the proper cipher method, as windows does only deliver some cipher-, encryption-, decryption-, encapsulating or hashing algorithms only up to 1024 bits.
```
Set-VpnConnectionIPsecConfiguration -ConnectionName "VPN" `
    -DHGroup Group2 `
    -EncryptionMethod AES256 `
    -IntegrityCheckMethod SHA256 `
    -AuthenticationTransformConstants SHA256128 `
    -CipherTransformConstants AES256 `
    -PfsGroup None `
    -Force
```

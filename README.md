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
Device Via SSH and Broadcast Data Like Audio, Video and Other Packages Internally.

## Server A
This is a low budget VPS from any provider of your choice.
I installed the newest FreeBSD image.
My Clients connect to this VPS via Wireguard.
  My Limited Android Phone Uses the Strongswan App, because builtin VPN support Is not supporting 
  Rooted Android Phones Can Use Wireguard instead.
  Windows Clients use the built-in
```
wget -qO- https://raw.githubusercontent.com/vi0lin/vpn_roadwarrior_configuration/refs/heads/main/server_a.sh | bash -s -- debug
```
I recommend using [Hetzner](https://www.hetzner.com) vps server. They offer under 5 Euro per month static ip dual core server with 20 TB traffic.

## Server B
This is low budget Workingstation for less than 60 Euro On Europerian Market.
It runs a freeBSD image
I configured it a Roadwarrior, that passes all my local devices to the connected VPN clients. This way my printer stays accessibile, even on holidays.
It forwards all my LAN Devices.
```
wget -qO- https://raw.githubusercontent.com/vi0lin/vpn_roadwarrior_configuration/refs/heads/main/server_b.sh | bash -s -- debug
```

## Client Google A14
Install the strongswan app.
Add the download and install the generated ca.cert
Add the VPN with the Username and Password,
Connect.

## Google Pixel 3a (postmarket os - sargo)
My Google Pixel 3a has a rooted system.
1. Hold Power & Volume Up Button
2. Unlock the bootloader
3. Quickly Install Ubuntu On A External Device (Live-System Runs out of memory)
4. Connect via USB to your Ubuntu System
5. Use pmbootstrap [Troubleshooting](https://wiki.postmarketos.org/wiki/Pmbootstrap/Installation)
```
git clone https://gitlab.postmarketos.org/postmarketOS/pmbootstrap.git
cd pmbootstrap
python3 pmbootstrap.py init
python3 pmbootstrap.py flasher flash_rootfs
python3 pmbootstrap.py flasher flash_flash_kernel
```

5. That should be it. [For More Information](https://wiki.postmarketos.org/wiki/Google_Pixel_3a_(google-sargo))

UI VPN Settins
Bring the wg0.conf file to the device,
Import wg0.conf as Wireguard configuration
Add The Username and the Password
Connect to the vpn.
Or execute the following in the terminal app:
```
wget -qO- https://raw.githubusercontent.com/vi0lin/vpn_roadwarrior_configuration/refs/heads/main/client_sargo.sh | bash -s -- debug
```

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

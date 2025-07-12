
# plan: 
# 1. detect system's hardware (collect know data)
# 2 setup tests with the data collected
# 3 run tests: look for errors, missing firmware, driver issues, anything suboptimal.
# 
# criteria: 
# be precise: onnly log and collect the speicific line. This scirpt will be less helpful if it logs hundrens of lines which are routine behavoir
#
# periferial support:
# known: brightnesscrl is for laptops screens not desktop monitors, montior may not have the correct firmware file but is able to commuicate with speakers, (pavcontrol worked)
# unless the monoitor speakser are not make by the same firm and are using a differneint chipset it should work and be able to ues features, backlight, bluelight, speakers,etc 





dmesg -t --level=err,warn | grep -i -e 'firmware' -e 'failed to load' -e 'drm' -e 'mt7925e' -e 'r8169'
lspci -k | grep -e 'VGA' -e 'Network controller' -e 'Ethernet controller' -A 3
# For MediaTek WiFi (mt7925e)
grep -i 'mt7925e' /sys/firmware/devicetree/base/model /proc/device-tree/model 2>/dev/null
journalctl -b | grep -i 'mt7925e'

# For AMD iGPU
grep -i 'amdgpu' /var/log/syslog | grep -i 'firmware'

# For Realtek Ethernet (r8169 driver)
dmesg | grep -i 'r8169' | grep -i 'firmware'
# Verify installed firmware packages
dpkg -l | grep -E 'firmware-misc-nonfree|firmware-linux-nonfree|firmware-realtek|firmware-mediatek'

# Check if firmware files exist
ls -l /lib/firmware/mediatek/mt7925e.bin
ls -l /lib/firmware/rtl_nic/rtl8125*
ls -l /lib/firmware/amdgpu/*.bin | head -n 5
# List module dependencies
modinfo mt7925e | grep -i 'firmware\|depends'
modinfo amdgpu | grep -i 'firmware'
modinfo r8169 | grep -i 'firmware'
# Check initramfs for missing firmware
sudo update-initramfs -u 2>&1 | grep -i 'missing'
# Install required firmware packages
sudo apt update
sudo apt install firmware-misc-nonfree firmware-amd-graphics firmware-realtek

# Rebuild initramfs
sudo update-initramfs -u

# Reload affected modules
sudo modprobe -r mt7925e amdgpu r8169
sudo modprobe mt7925e amdgpu r8169

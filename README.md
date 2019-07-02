# xps15 9570 arch post install scripts

Shell script to fix some issue with xps15 9570 and arch linux install
* New install defaults to s2idle suspend mode which drains noticable amount of battery during suspension
* bbswitch does not work with xps15 9570
  * we must manually configure switching between the two GPU's
  * ```sudo ./enableGPU.sh```
  * ```sudo ./disableGPU.sh```

## Installing
To run the script do the following:

```
wget https://raw.githubusercontent.com/DWShuo/xps15-9570_arch_postInstall_scripts/master/xps15-9570Arch_postInstall_fix.sh
```
then make script executable

```
chmod u+x xps15-9570Arch_postInstall_fix.sh
```
run the script as root

```
sudo ./xps15-9570Arch_postInstall_fix.sh
```
Reboot your computer and test if it was successful

## Test
First lets see if suspend has been set to deep mode

```cat /sys/power/mem_sleep```

should return this

``` s2idle [deep]```

Next lets check if GPU switching is working
1. unplug the power cord
2. run ```lsmod | grep nvidia```
    1. Should return blank
3. check the discharge rate(should be 5.0W to 10.0W) via powertop (keep an eye on this)
4. enable discrete gpu ```sudo ./enableGPU.sh```
    1. check that its loaded with ```nvidia-smi```
5. ```optirun glxgears```
6. check powertop again, the power draw should be alot higher now.
7. exit out of glxgear, and swtich back to integrated gpu
    1. ```sudo ./disableGPU.sh```
8. check powertop one last time, the power draw should have died down to around 5.0W to 10.0W




## Author

* **David Wang**

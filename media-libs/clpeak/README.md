By default we ship clpeak on ChromeOS test builds so you do not need to build the binaries yourself
simply run /usr/local/opencl/clpeak
you should see output similar to this :
https://github.com/krrishnarraj/clpeak#sample

If you wish to build once you have a ChromeOS checkout and chroot working just follow these simple instructions:

# build
emerge-${BOARD} clpeak
# deploy
cros deploy <dut> clpeak
# run
ssh <dut> /usr/local/opencl/clpeak

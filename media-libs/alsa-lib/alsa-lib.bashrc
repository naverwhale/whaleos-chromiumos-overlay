# Use the ucm file installed by media-sound/adhd
if [[ $(cros_target) != "cros_host" ]] ; then
	alsalib_mask=/usr/share/alsa/ucm/DAISY-I2S
	PKG_INSTALL_MASK+=" ${alsalib_mask}"
	INSTALL_MASK+=" ${alsalib_mask}"
	unset alsalib_mask
fi

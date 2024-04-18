# Some applications may use /etc/machine-id, if available, so ensure that
# it's available and unique per OS instance. https://crbug.com/221678
cros_post_pkg_postinst_dbus_mung_machineid() {
  ln -sfT /var/lib/dbus/machine-id "${ROOT}"/etc/machine-id
}

# Modify D-Bus system conf to include an additional directory,
# /usr/local/etc/dbus-1/system.d, after /etc/dbus-1/system.d
cros_post_src_install_dbus_include_usr_local_conf() {
  sed -i 's/<includedir>\/etc\/dbus\-1\/system\.d<\/includedir>/&\n  <includedir>\/usr\/local\/etc\/dbus\-1\/system\.d<\/includedir>/' "${D}"/usr/share/dbus-1/system.conf
}

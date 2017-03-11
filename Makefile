#http://www.ntop.org/
include $(TOPDIR)/rules.mk

PKG_NAME:=ndpi
PKG_RELEASE:=1.8

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/uclibc++.mk
include $(INCLUDE_DIR)/package.mk


define Package/ndpi-ipt
  SECTION:=oem
  CATEGORY:=OEM
  TITLE:=ndpi-ipt
  DEPENDS:=+libjson-c +libpthread +libpcap +libc
endef

define Package/ndpi
  SECTION:=oem
  CATEGORY:=OEM
  TITLE:=ndpi
  DEPENDS:=+libjson-c +libpthread +libpcap +libc
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)
endef

#define Package/ndpi-ipt/configure
#	$(call Build/Configure/Default)
#endef

TARGET_CFLAGS += -fPIC -I$(PKG_BUILD_DIR)/ndpi/include -I$(PKG_BUILD_DIR)/ndpi/src/include -I$(PKG_BUILD_DIR)/ndpi/lib -I../src -I$(STAGING_DIR)/usr/include -DOPENDPI_NETFILTER_MODULE -O2 -Wall -DNDPI_IPTABLES_EXT

define Build/Configure
	(cd $(PKG_BUILD_DIR)/ndpi; rm -f configure config.h config.h.in src/lib/Makefile.in ; autoreconf -ifv ;\
	./autogen.sh; \
	./configure --with-pic --host=$(GNU_TARGET_NAME);\
	);
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR)/ndpi
	$(MAKE) -C $(PKG_BUILD_DIR)/ipt \
			$(TARGET_CONFIGURE_OPTS) \
			CFLAGS="$(TARGET_CFLAGS)" \
			CPPFLAGS="$(TARGET_CPPFLAGS)" \
			LDFLAGS="$(TARGET_LDFLAGS)"
endef

#define Package/ndpi/install
#	$(INSTALL_DIR) $(1)/usr/lib
#	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ndpi/lib/libndpi.so*  $(1)/usr/lib/ 
#endef

define Package/ndpi-ipt/install
	$(INSTALL_DIR) $(1)/usr/lib/iptables
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ipt/libxt_ndpi.so  $(1)/usr/lib/iptables/
endef

$(eval $(call BuildPackage,ndpi-ipt))
$(eval $(call BuildPackage,ndpi))


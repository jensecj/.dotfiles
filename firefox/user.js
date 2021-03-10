user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true); // load userChrome / userContent
user_pref("general.warnOnAboutConfig", false); // XUL/XHTML version
user_pref("security.dialog_enable_delay", 0);   // dont delay the download-file dialog
user_pref("privacy.userContext.ui.enabled", true);
user_pref("privacy.userContext.enabled", true);
user_pref("browser.aboutConfig.showWarning", false); // HTML version [FF71+]
user_pref("toolkit.cosmeticAnimations.enabled", false);
user_pref("browser.tabs.insertAfterCurrent", true);
user_pref("general.smoothScroll.currentVelocityWeighting", "0.55");
user_pref("browser.fullscreen.autohide", false);
user_pref("full-screen-api.warning.timeout", 0); // dont show popup when going fullscreen
user_pref("dom.event.contextmenu.enabled", false); // dont let pages hijack rightclick
user_pref("dom.event.clipboardevents.enabled", false); // dont tell websites if i copy/paste things
user_pref("dom.disable_beforeunload", true);       // dont let pages hijack 'back'
user_pref("browser.shell.checkDefaultBrowser", false);
user_pref("browser.urlbar.trimURLs", false); // show full url to see if http or https
user_pref("webgl.disabled", true);
user_pref("dom.webnotifications.enabled", false);
user_pref("media.webspeech.synth.enabled", false);
user_pref("dom.gamepad.enabled", false);
user_pref("dom.vr.enabled", false);
user_pref("dom.vibrator.enabled",           false);
user_pref("dom.enable_resource_timing", false);
user_pref("camera.control.face_detection.enabled", false);
user_pref("browser.search.countryCode", "US");
user_pref("browser.search.region", "US");
user_pref("browser.search.geoip.url", "");
user_pref("intl.accept_languages", "en-US, en");
user_pref("intl.locale.matchOS", false);
user_pref("javascript.use_us_english_locale", true);
user_pref("clipboard.autocopy", false);
user_pref("apz.gtk.kinetic_scroll.enabled", false); // dont imitate physics while scrolling

// privacy and telemetry
user_pref("privacy.firstparty.isolate", true);
user_pref("privacy.resistFingerprinting", true);
user_pref("privacy.trackingprotection.fingerprinting.enabled", true);
user_pref("privacy.trackingprotection.cryptomining.enabled", true);
user_pref("plugin.state.java", 0);
user_pref("plugin.state.flash", 0);
user_pref("extensions.getAddons.cache.enabled", false);
user_pref("browser.display.use_document_fonts", 0); // try to prevent font fingerprinting
user_pref("general.buildID.override", "20100101");
user_pref("browser.startup.homepage_override.buildID", "20100101");
user_pref("browser.send_pings.require_same_host", true);
user_pref("media.webspeech.recognition.enable", false);
user_pref("browser.send_pings", false);
user_pref("media.peerconnection.enabled", false);
user_pref("extensions.htmlaboutaddons.recommendations.enabled", false);
user_pref("extensions.htmlaboutaddons.discover.enabled", false);
user_pref("geo.enabled", false);
user_pref("browser.newtabpage.directory.ping", "");
user_pref("browser.newtabpage.directory.source", "data:text/plain,{}");
user_pref("browser.newtabpage.enhanced", false);
user_pref("browser.search.geoip.url", "");
user_pref("browser.search.region", "US");
user_pref("browser.search.suggest.enabled", false);
user_pref("browser.search.update", false);
user_pref("browser.selfsupport.url", "");
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("datareporting.healthreport.service.enabled", false);
user_pref("datareporting.policy.dataSubmissionEnabled", false);
user_pref("datareporting.sessions.current.clean", true);
user_pref("device.sensors.enabled", false);
user_pref("dom.battery.enabled", false);
user_pref("dom.enable_performance", false); // disable the timing api
user_pref("dom.enable_user_timing", false); // also disable the user timing api
user_pref("dom.netinfo.enabled", false); // dont leak network/browser information through javascript
user_pref("dom.telephony.enabled", false);
user_pref("extensions.getAddons.cache.enabled", false);
user_pref("extensions.pocket.enabled", false);
user_pref("media.getusermedia.screensharing.enabled", false);
user_pref("media.getusermedia.audiocapture.enabled", false);
user_pref("media.navigator.video.enabled", false);
user_pref("media.navigator.enabled", false);
user_pref("beacon.enabled", false);
user_pref("media.video_stats.enabled", false);
user_pref("network.dns.disablePrefetch", true);
user_pref("network.http.speculative-parallel-limit", 0);
user_pref("network.predictor.cleaned-up", true);
user_pref("network.predictor.enabled", false);
user_pref("network.prefetch-next", false);
user_pref("privacy.donottrackheader.enabled", true);
user_pref("privacy.trackingprotection.enabled", true);
user_pref("privacy.trackingprotection.introCount", 20);
user_pref("browser.newtabpage.activity-stream.feeds.telemetry", false);
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr", false);
user_pref("browser.newtabpage.activity-stream.telemetry", false);
user_pref("browser.newtabpage.activity-stream.feeds.section.topstories", false);
user_pref("browser.ping-centre.telemetry", false);
user_pref("toolkit.telemetry.enabled", false);
user_pref("toolkit.telemetry.firstShutdownPing.enabled", false);
user_pref("toolkit.telemetry.hybridContent.enabled", false);
user_pref("toolkit.telemetry.newProfilePing.enabled", false);
user_pref("toolkit.telemetry.shutdownPingSender.enabled", false);
user_pref("toolkit.telemetry.updatePing.enabled", false);
user_pref("toolkit.telemetry.server", "");
user_pref("toolkit.telemetry.reportingpolicy.firstRun", false);
user_pref("toolkit.telemetry.unified", false);
user_pref("toolkit.telemetry.archive.enabled", false);
user_pref("devtools.onboarding.telemetry.logged", false);
user_pref("toolkit.telemetry.bhrPing.enabled", false);
user_pref("browser.onboarding.enabled", false);
user_pref("experiments.enabled", false);
user_pref("network.allow-experiments", false);
user_pref("social.directories", "");
user_pref("social.remote-install.enabled", false);
user_pref("social.toast-notifications.enabled", false);
user_pref("social.whitelist", "");
user_pref("dom.ipc.plugins.reportCrashURL", false);
user_pref("breakpad.reportURL", "");
user_pref("browser.safebrowsing.blockedURIs.enabled", false);
user_pref("browser.safebrowsing.downloads.enabled", false);
user_pref("browser.safebrowsing.downloads.remote.enabled", false);
user_pref("browser.safebrowsing.malware.enabled", false);
user_pref("browser.safebrowsing.phishing.enabled", false);
user_pref("extensions.screenshots.disabled", true);
user_pref("extensions.screenshots.system-disabled", true);
user_pref("extensions.screenshots.upload-disabled", true);
user_pref("loop.logDomains", false);
user_pref("extensions.shield-recipe-client.enabled", false);
user_pref("app.shield.optoutstudies.enabled", false);
user_pref("network.negotiate-auth.allow-insecure-ntlm-v1", false);
user_pref("network.http.referer.spoofSource", true);

Floss IMS source integration
============================

Source: jaso1000/Fold3-LineageOS, floss-ims/ (GPL-2.0)
Revision: 91583514419f9a919fb751efd037c2a9070be6c5
Upstream: https://github.com/jaso1000/Fold3-LineageOS

This is the Fold3-specific Phh/Floss IMS implementation and its Soong build
metadata. The source includes the upstream project’s Fold3/Telstra fixes. The
q2q device tree packages it as a platform-signed privileged app and selects it
as the MMTEL service. Carrier IMS registration still depends on carrier support
and a usable IMS APN/network; Happybytes settings here are an initial
configuration inferred from the project’s documented requirements, not a
confirmed Happybytes IMS profile.

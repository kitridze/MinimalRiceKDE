// OPTIONAL, untested sketch: adds a NEW floating top panel (workspaces | clock | tray) in the spirit of the Waybar bar.
// It does not remove your existing panel; delete that one yourself in Edit Mode.
// Run:  busctl --user call org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell evaluateScript s "$(cat rice-panel.js)"
// Afterwards, in Edit Mode set the panel's Opacity to Translucent. CPU/RAM: Add Widgets > "System Monitor Sensor".
var p = new Panel();
try { p.location = "top"; } catch (e) {}
try { p.height = 32; } catch (e) {}
try { p.floating = true; } catch (e) {}
function add(id) { try { p.addWidget(id); } catch (e) {} }
add("org.kde.plasma.pager");
add("org.kde.plasma.panelspacer");
add("org.kde.plasma.digitalclock");
add("org.kde.plasma.panelspacer");
add("org.kde.plasma.systemtray");

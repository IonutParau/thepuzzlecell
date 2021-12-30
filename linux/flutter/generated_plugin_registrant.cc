//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <dart_discord_rpc/dart_discord_rpc_plugin.h>
#include <dart_vlc/dart_vlc_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) dart_discord_rpc_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "DartDiscordRpcPlugin");
  dart_discord_rpc_plugin_register_with_registrar(dart_discord_rpc_registrar);
  g_autoptr(FlPluginRegistrar) dart_vlc_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "DartVlcPlugin");
  dart_vlc_plugin_register_with_registrar(dart_vlc_registrar);
}

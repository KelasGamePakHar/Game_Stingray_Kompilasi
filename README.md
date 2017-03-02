# Game Stingray Kompilasi
Game Stingray Kompilasi tiga kelasnya pak Har (Game Engine, Oop Game, Desain Game)
## Setting Untuk Komputer Potato
Bagi yang merasa stingray berjalan lambat, berat atau hanya ingin agar hemat energi silahkan gunakan cara berikut.

- Buka folder project (bukan _wwise/_data).
- Buka file settings.ini.
- Tirukan seperti dibawah.

```
renderer = {
  screen_resolution = [ 1280, 720 ]
  adapter_index = 0
  fullscreen_output = 0
  fullscreen = false
  aspect_ratio = -1
  d3d_debug = false
  //vsync = false
}

// Note: Adjust render settings below
render_settings = {
  sun_shadows = false
  sun_shadow_map_size = [ 32, 32 ]
  // Only on PC, PS4, XB1: medium == 4 tap PCF, high == 5x5 PCF
  // Ignored on mobile
  sun_shadow_map_filter_quality = "low"
  local_lights_shadow_map_filter_quality = "low"

  deferred_local_lights_cast_shadows = false
  forward_local_lights_cast_shadows = false
  local_lights_shadow_atlas_size = [ 32, 32 ]

  particles_local_lighting = false
  particles_receive_shadows = false
  particles_tessellation = false
  particles_cast_shadows = false

  local_lights = false
  fxaa_enabled = false
  taa_enabled = false
  motion_blur_enabled = false
  ao_enabled = false
  //ao_half_res = false
  dof_enabled = false
  bloom_enabled = false
  ssr_enabled = false
  ssr_high_quality = false
  lens_quality_enabled = false
}
```

- Save dan restart stingray.

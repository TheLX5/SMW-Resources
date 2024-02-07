; Macro library file.
; You can add your own defines or macros that will be included by all resources/libraries/etc.

;##################################################################################################
;# SA-1 Max Tile defines
;# 
;# This file is used to help resources use the MaxTile APi very easily.
;# More info here: https://github.com/VitorVilela7/SA1-Pack/blob/max-tile/docs/maxtile.md#api

;#########################################################################
;# Shared routines

;# !maxtile_flush_nmstl
;# Flushes $0338-$03FC to the MaxTile internal buffer (priority #3).
;# Input params:
;#  - AXY 8-bit

    !maxtile_flush_nmstl            = $0084A8

;# !maxtile_get_sprite_slot
;# Allocate and get OAM pointer from MaxTile. Difference between get_oam_slot_general is:
;#  - Amount of slots is passed via "A"
;#  - No 16-bit AXY required.
;#  - Slot is also copied to $0C ($3100) and $0E ($3102).

    !maxtile_get_sprite_slot        = $0084AC

;# !maxtile_get_slot
;# Allocate and get OAM pointer from MaxTile.
;# The routine automatically adjusts internal MaxTile pointers for you.
;# Input params:
;#  - AXY 16-bit
;#  - Y = how many slots to be allocated (min: #$0001 - 1 slot, max: #$0080 - 128 slots)
;#  - A = priority (0: highest, 3: lowest)
;# Output params:
;#  - Carry set if the OAM allocation was success, carry clear otherwise.
;#  - $3100-$3101 will contain the pointer to the OAM general buffer.
;#  - $3102-$3103 will contain the pointer to the OAM attribute buffer.
;#  - The pointer returned is intended to be incremented, just like normal OAM drawing routines.
;#  - $3100-$3103 will be used by FinishOAMWrite routine version MaxTile.

    !maxtile_get_slot               = $0084B0

;# !maxtile_finish_oam
;# Same as FinishOAMWrite ($01B7B3), but it's made to use MaxTile pointers.
;# It will use the pointers placed on $3100 and $3102.
;# Input params:
;#  - AXY 8-bit
;#  - Y = the tile size (#$00 or #$02) or #$FF to keep the tilesize unchanged.
;#  - A = how many slots minus 1

    !maxtile_finish_oam             = $0084B4
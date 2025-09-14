#ANNA ON IRC.RIZON.NET #WORLD-CHAT 2022
; Path to store user balances
alias balancefile return user_balances.ini

\

; Handle text commands in the channel
on *:TEXT:*:#: {

  ; Anti-spam mechanism: ignore user if they repeat a command too frequently
  if ($($+(%,spam_ignore.,$nick),2)) {
    halt
  }

  ; Increment spam count for each command usage
  inc -u10 %spam_count. $+ $nick

  ; If the user exceeds 10 commands in 10 seconds, set ignore for 30 seconds
  if (%spam_count. [ $+ [ $nick ] ] > 10) {
    set -u30 %spam_ignore. $+ $nick 1
    msg $chan $nick, you've been temporarily ignored for spamming commands. Please wait for 30 seconds.
    halt
  }

  ; Command: .buy shield (protects user from mugging for 15 minutes, costs 1/5 of their balance)
  if ($1 == .buy) && ($2 == shield) {
    var %balance = $readini($balancefile, Users, $nick)
    if (%balance <= 0) {
      msg $chan $nick, you don’t have enough money to buy a shield.
    }
    elseif ($($+(%,shield_active.,$nick),2)) {
      msg $chan $nick, you already have an active shield.
    }
    else {
      var %cost = $int($calc(%balance / 5))
      writeini $balancefile Users $nick $calc(%balance - %cost)
      set -u900 %shield_active. $+ $nick 1
      msg $chan $nick, you bought a shield for $ %cost ! You are now protected from mugging for 15 minutes and it cost you 1/5 of your benez. Your new balance is $ $+ $readini($balancefile, Users, $nick).
    }
  }

  ; Command: .buy power (50/50 mugging success chance for 15 minutes, costs 1/3 of their balance)
  if ($1 == .buy) && ($2 == power) {
    var %balance = $readini($balancefile, Users, $nick)
    if (%balance <= 0) {
      msg $chan $nick, you don’t have enough money to buy power.
    }
    elseif ($($+(%,power_active.,$nick),2)) {
      msg $chan $nick, you already have active power.
    }
    else {
      var %cost = $int($calc(%balance / 3))
      writeini $balancefile Users $nick $calc(%balance - %cost)
      set -u900 %power_active. $+ $nick 1
      msg $chan $nick, you bought power for $ %cost ! Mugging success chance is now 50/50 for 15 minutes. Your new balance is $ $+ $readini($balancefile, Users, $nick).
    }
  }
  ; Command: .bene (gives the user a random amount between $50 and $500 with a 5-minute cooldown)
  if ($1 == .bene) {
    ; Check if user is on cooldown
    if ($($+(%,bene_cooldown.,$nick),2)) {
      ; Get cooldown start time
      var %cooldown_start = $($+(%,bene_cooldown_time.,$nick),2)
      ; Calculate seconds left (300 seconds = 5 minutes)
      var %seconds_left = $calc(300 - ($ctime - %cooldown_start))
      if (%seconds_left > 0) {
        ; Convert to minutes and seconds
        var %minutes = $int($calc(%seconds_left / 60))
        var %seconds = $calc(%seconds_left % 60)
        msg $chan $nick, 0,64u 00,52w00,40h00,28o00,1r00,64e 00,52u 00,40g00,28o00,1t00,64t00,52a 00,40w00,288 12 $+ %minutes minute $+ $iif(%minutes != 1,s) and %seconds second $+ $iif(%seconds != 1,s) before begging for .bene'z again.
        halt
      }
      ; Clear expired cooldown
      unset %bene_cooldown. $+ $nick
      unset %bene_cooldown_time. $+ $nick
    }
    ; Set cooldown with timestamp
    set -u300 %bene_cooldown. $+ $nick 1
    set -u300 %bene_cooldown_time. $+ $nick $ctime
    ; Original currency logic
    var %amount = $rand(1050, 2000)
    var %balance = $readini($balancefile, Users, $nick)
    writeini $balancefile Users $nick $calc(%balance + %amount)
    msg $chan 8 $+ $nick $+  received 3 $+ $ $+ %amount $+ ! 4Y06o02u12r 11n03e09w 08b07a04l06a02n12c11e 03i09s3 $chr(36) $+ $readini($balancefile, Users, $nick).
  }
  if ($1 == .bank) {
    if ($2) {
      var %target = $2
      if (!$readini($balancefile, Users, %target)) {
        msg $chan $nick, $2 does not exist.
      }
      else {
        var %balance = $readini($balancefile, Users, %target)
        msg $chan Their 11current 13balance 08is $ $+ %balance
      }
    }
    else {
      var %balance = $readini($balancefile, Users, $nick)
      msg $chan $nick, your 11current 13balance 08is $ $+ %balance
    }
  }
  ; Command: .give <user> <amount>
  if ($1 == .give) && ($2) && ($3 isnum) {
    var %recipient = $2
    var %amount = $3
    var %giver_balance = $readini($balancefile, Users, $nick)
    if (%amount <= 0) {
      msg $chan $nick, you need to specify a positive amount.
    }
    elseif (%giver_balance < %amount) {
      msg $chan $nick, you do not have enough money to give.
    }
    elseif (!$readini($balancefile, Users, %recipient)) {
      msg $chan $nick, the user $2 does not exist.
    }
    else {
      writeini $balancefile Users $nick $calc(%giver_balance - %amount)
      var %recipient_balance = $readini($balancefile, Users, %recipient)
      writeini $balancefile Users %recipient $calc(%recipient_balance + %amount)
      msg $chan $nick gave $2 3 $+ $chr(36) $+ $3! $nick $+ 's new balance is3 $chr(36) $+ $readini($balancefile, Users, $nick).  $+ $2's new balance is now 3 $+ $chr(36) $+ $readini($balancefile, Users, %recipient).
    }
  }


  ; Command: .mug <user> (with a 2-minute cooldown and 10% success rate)
  if ($1 == .mug) && ($2) {
    ; Check if cooldown exists
    if ($($+(%,mug_cooldown.,$nick),2)) {
      var %remaining = $calc($($+(%,mug_cooldown.,$nick),2) - $ctime)
      if (%remaining > 0) {
        var %minutes = $int($calc(%remaining / 60))
        var %seconds = $calc(%remaining % 60)
        msg $chan $nick, 0,73u 00,74s00,75l00,71u00,72t00,73, 00,74y00,75o00,71u 00,72n00,73e00,74e00,75d 00,71t00,72o 00,73w00,74a00,75i00,71t %minutes minutes and4 %seconds seconds 0,72b00,73e00,74f00,75o00,71r00,72e 00,73y00,74o00,75u 00,71c00,72a00,73n 00,74m00,75u00,71g 00,72a00,73g00,74a00,75i00,71n00,72!
        halt
      }
    }

    ; Set a 2-minute cooldown
    set %mug_cooldown. $+ $nick $calc($ctime + 120)

    ; Ensure the target user exists in the balance file
    var %target = $2
    if (!$readini($balancefile, Users, %target)) {
      msg $chan $nick, $2 does not exist.
      halt
    }
    ; Check if the target has a shield
    if ($($+(%,shield_active.,%target),2)) {
      msg $chan $nick, $2 is protected by a shield. Mugging failed!
      halt
    }
    ; Determine mugging success (10% success rate)
    var %success_chance = $rand(1, 3)
    if (%success_chance <= 1) {  ; Successful mugging
      var %target_balance = $readini($balancefile, Users, %target)
      if (%target_balance < 20) {
        msg $chan $nick, $2 doesn't have enough money to be mugged.
      }
      else {
        var %mug_amount = $rand(20, $calc(%target_balance * 0.3))
        writeini $balancefile Users %target $calc(%target_balance - %mug_amount)
        var %mugger_balance = $readini($balancefile, Users, $nick)
        writeini $balancefile Users $nick $calc(%mugger_balance + %mug_amount)
        msg $chan 9OMG $nick 9you 11managed 13to 08mug $2 6for3 $ %mug_amount $+ ! $nick $+ 's new balance is3 $chr(36) $+ $readini($balancefile, Users, $nick). $2's 0new balance is3 $chr(36) $+ $readini($balancefile, Users, %target).
      }
    }
    else {  ; Failed mugging, apply penalty
      var %penalty = $rand(500, 1000)
      var %user_balance = $readini($balancefile, Users, $nick)
      if (%user_balance >= %penalty) {
        writeini $balancefile Users $nick $calc(%user_balance - %penalty)
        msg $chan $nick, 9FAIL! 2,2 0,1DOCTOR4,4 2,2  Its the warden! looks like u need horse tranquilizer injection for your autism! for TWO minutes you are unable to speak, only drool. It cost you 3 $chr(36) $+ %penalty to get out of the 4HOSPITAL 0,63u00,61r 00,62n00,63u 00,61b00,62a00,63l00,61a00,62n00,63c00,61e is3 $chr(36) $+ $readini($balancefile, Users, $nick).
      }
      else {
        msg $chan $nick, 9FAIL! Mugging failed, but you don’t have enough money to pay the penalty. You're now completely broke!
        writeini $balancefile Users $nick 0
      }
    }
  }

  ; Command: !top10 (shows the top 10 users with the most money)
  if ($1 == .top5) {
    var %i = 1
    var %users = $ini($balancefile, Users, 0)
    var %scores = ""

    ; Iterate over each user in the INI file and prepare for sorting
    while (%i <= %users) {
      var %nick = $ini($balancefile, Users, %i)
      var %balance = $readini($balancefile, Users, %nick)
      var %scores = %scores $+ %balance $+ $chr(44) $+ %nick $+ $chr(124)
      inc %i
    }

    ; Sort the scores in descending order by balance
    var %sorted = $sorttok(%scores, 124, rn)

    ; Output the top 10 users
    msg $chan 56Top 59 $+ 10 63Richest 68Users:
    var %i = 1
    while (%i <= 10) && ($gettok(%sorted, %i, 124) != $null) {
      var %user_entry = $gettok(%sorted, %i, 124)
      var %balance = $gettok(%user_entry, 1, 44)
      var %nick = $gettok(%user_entry, 2, 44)
      msg $chan 9 %i $+ 11 %nick - 3$4 %balance
      inc %i
    }
  }
  ; Command: .bet <amount>
  if ($1 == .bet) && ($2 isnum) {
    var %amount = $2
    var %balance = $readini($balancefile, Users, $nick)
    if (%amount > %balance) {
      msg $chan $nick, you do not have enough money to place this bet.
    }
    elseif (%amount <= 0) {
      msg $chan $nick, you need to bet a positive amount.
    }
    else {
      var %result = $rand(0, 1)
      if (%result == 1) {
        writeini $balancefile Users $nick $calc(%balance + %amount)
        msg $chan 62woooot   $+ $nick wins! ur nu 13balance is3 $chr(36) $+ $readini($balancefile, Users, $nick).
      }
      else {
        writeini $balancefile Users $nick $calc(%balance - %amount)
        msg $chan 13hahahaha u slut  $+ $nick $+  9fails! ur new 13balance is3 $chr(36) $+ $readini($balancefile, Users, $nick).
      }
    }
  }

  ; Command: .commands (lists all available commands)
  if ($1 == .commands) {
    notice $nick Available commands: .bene, .give <user> <amount>, .mug <user>, .bet <amount>, .bank, .top5, .buy shield (15 minutes of shielding for 1/3 of your benes), .buy power (mugging success 50/50 for 15 minutes costing you 1/3 of your benes!
  }
}

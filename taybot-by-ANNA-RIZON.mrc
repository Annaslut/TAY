
View Paste
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

  ; Command: .bene (gives the user a random amount between $50 and $500 with a 5-minute cooldown)
  if ($1 == .bene) {
    if ($($+(%,bene_cooldown.,$nick),2)) {
      msg $chan $nick, u whore u gotta w8 12FIVE minutes before begging for .bene'z again.
      halt
    }
    set -u300 %bene_cooldown. $+ $nick 1
    var %amount = $rand(50, 2000)
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
        msg $chan $nick, u slut, you need to wait4 %minutes minutes and4 %seconds seconds before you can mug again!
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

    ; Determine mugging success (10% success rate)
    var %success_chance = $rand(1, 10)
    if (%success_chance <= 1) {  ; Successful mugging
      var %target_balance = $readini($balancefile, Users, %target)
      if (%target_balance < 20) {
        msg $chan $nick, $2 doesn't have enough money to be mugged.
      }
      else {
        var %mug_amount = $rand(20, $calc(%target_balance * 0.3)) ; Up to 30% of target's balance
        writeini $balancefile Users %target $calc(%target_balance - %mug_amount)
        var %mugger_balance = $readini($balancefile, Users, $nick)
        writeini $balancefile Users $nick $calc(%mugger_balance + %mug_amount)
        msg $chan 9OMG $nick 9you 11managed 13to 08mug $2 6for3 $ %mug_amount $+ ! $nick $+ 's new balance is3 $chr(36) $+ $readini($balancefile, Users, $nick). $2's 0new balance is3 $chr(36) $+ $readini($balancefile, Users, %target).
      }
    }
    else {  ; Failed mugging, apply penalty
      var %penalty = $rand(1000, 10000)
      var %user_balance = $readini($balancefile, Users, $nick)
      if (%user_balance >= %penalty) {
        writeini $balancefile Users $nick $calc(%user_balance - %penalty)
        msg $chan $nick, 9FAIL! Mugging failed, and it cost you3 $chr(36) $+ %penalty to bail out of 4JAIL Your new balance is3 $chr(36) $+ $readini($balancefile, Users, $nick).
      }
      else {
        msg $chan $nick, 9FAIL! Mugging failed, but you don’t have enough money to pay the penalty. You're now completely broke!
        writeini $balancefile Users $nick 0
      }
    }
  }

  ; Command: .top5 (shows the top 5 users with the most money)
  if ($1 == .top5) {
    var %i = 1
    var %users = $ini($balancefile, Users, 0)
    var %scores = ""

    ; Iterate over each user in the ini file and prepare for sorting
    while (%i <= %users) {
      var %nick = $ini($balancefile, Users, %i)
      var %balance = $readini($balancefile, Users, %nick)
      var %scores = %scores $+ %balance $+ $chr(44) $+ %nick $+ $chr(124)
      inc %i
    }

    ; Sort the scores in descending order by balance
    var %sorted = $sorttok(%scores, 124, rn)

    ; Output the top 5 users
    msg $chan 09Top 115 13Richest 08Users:
    var %i = 1
    while (%i <= 5) && ($gettok(%sorted, %i, 124) != $null) {
      var %user_entry = $gettok(%sorted, %i, 124)
      var %balance = $gettok(%user_entry, 1, 44)
      var %nick = $gettok(%user_entry, 2, 44)
      msg $chan %i. %nick - $ %balance
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
    notice $nick Available commands: .bene, .give <user> <amount>, .mug <user>, .bet <amount>, .bank, .top5
  }
}

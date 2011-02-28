(*
 * lt_term.mli
 * -----------
 * Copyright : (c) 2011, Jeremie Dimino <jeremie@dimino.org>
 * Licence   : BSD3
 *
 * This file is a part of Lambda-Term.
 *)

(** Terminal definitions *)

open React

type t
  (** Type of terminals. *)

(** {6 Creation} *)

val create :
  ?windows : bool ->
  ?model : string ->
  ?incoming_encoding : string ->
  ?outgoing_encoding : string ->
  Lwt_unix.file_descr -> Lwt_unix.file_descr -> t
  (** [create ?windows ?model ?incoming_encoding ?outgoing_encoding
      input_fd outout_fd] creates a new terminal using [input_fd] for
      inputs and [output_fd] for outputs.

      - [windows] is a flag telling whether windows hack should be
      used. It defaults to [Lwt_sys.windows].

      - [model] is the type of the terminal, such as "rxvt" or
      "xterm". It defaults to the contents of the "TERM" environment
      variable, or to "dumb" if this one is not found. It is used to
      determine capabilities of the terminal, such as the number of
      colors. This is not used if [windows] is [true].

      - [incoming_encoding] is the encoding used for incoming data. It
      defaults to [Lt_windows.get_console_cp] if [windows] is [true]
      and [Lt_unix.system_encoding] otherwise.

      - [outgoing_encoding] is the encoding used for outgoing data. It
      defaults to [Lt_windows.get_console_output_cp] if [windows] is
      [true] and [Lt_unix.system_encoding] otherwise. Note that
      transliteration is used so printing unicode character on the
      terminal will never fail. *)

(** {6 Informations} *)

val model : t -> string
  (** Returns the model of the terminal. *)

val colors : t -> int
  (** Number of colors of the terminal. *)

val windows : t -> bool
  (** Whether the terminal is in windows mode or not. *)

(** {6 Sizes} *)

val get_size : t -> Lt_types.size Lwt.t
  (** Returns the current size of the terminal. *)

val set_size : t -> Lt_types.size -> unit Lwt.t
  (** Sets the current size of the terminal. *)

(** {6 Modes} *)

val raw_mode : t -> bool signal
  (** Whether the terminal is in ``raw mode''. In this mode keyboard
      events are returned as they happen. In normal mode only complete
      line are returned. *)

val enter_raw_mode : t -> unit Lwt.t
  (** Put the terminal in raw mode. On windows this does nothing
      except setting {!raw_mode} to [true]. *)

val leave_raw_mode : t -> unit Lwt.t
  (** Put the terminal in normal mode. On windows this does nothing
      except setting {!raw_mode} to [false]. *)

val mouse_mode : t -> bool signal
  (** Wether the mouse mode is enabled. In this mode mouse event are
      reported to the application. *)

val enter_mouse_mode : t -> unit Lwt.t
  (** Enable mouse events reporting. *)

val leave_mouse_mode : t -> unit Lwt.t
  (** Disable mouse events reporting. *)

(** {6 State} *)

val save : t -> unit Lwt.t
  (** Save the current state of the terminal so it can be restored
      latter. *)

val load : t -> unit Lwt.t
  (** Load the previously saved state of the terminal. *)

(** {6 Events} *)

val read_event : t -> Lt_event.t Lwt.t
  (** Reads and returns one event. This method can be called only when
      the terminal is in raw mode. Otherwise several kind of events
      will not be reported. *)

(** {6 Printing} *)

(** The general name of a printing function is [<prefix>print<suffixes>].

    Where [<prefix>] is one of:
    - ['f'], which means that the function takes as argument a terminal
    - nothing, which means that the function prints on {!stdout}
    - ['e'], which means that the function prints on {!stderr}

    and [<suffixes>] is a combination of:
    - ['l'] which means that a new-line character is printed after the message
    - ['f'] which means that the function takes as argument a {b format} instead
    of a string
    - ['s'] which means that the function takes as argument a styled
    string instead of a string

    Notes:
    - if the terminal is not really a terminal, styles are stripped.
    - non-ascii characters are recoded on the fly using the terminal
    encoding
*)

val fprint : t -> string -> unit Lwt.t
val fprintl : t -> string -> unit Lwt.t
val fprintf : t -> ('a, unit, string, unit Lwt.t) format4 -> 'a
val fprints : t -> Lt_style.text -> unit Lwt.t
val fprintlf : t -> ('a, unit, string, unit Lwt.t) format4 -> 'a
val fprintls : t -> Lt_style.text -> unit Lwt.t
val print : string -> unit Lwt.t
val printl : string -> unit Lwt.t
val printf : ('a, unit, string, unit Lwt.t) format4 -> 'a
val prints : Lt_style.text -> unit Lwt.t
val printlf : ('a, unit, string, unit Lwt.t) format4 -> 'a
val printls : Lt_style.text -> unit Lwt.t
val eprint : string -> unit Lwt.t
val eprintl : string -> unit Lwt.t
val eprintf : ('a, unit, string, unit Lwt.t) format4 -> 'a
val eprints : Lt_style.text -> unit Lwt.t
val eprintlf : ('a, unit, string, unit Lwt.t) format4 -> 'a
val eprintls : Lt_style.text -> unit Lwt.t

(** {6 Well known instances} *)

val stdout : t
  (** Terminal using {!Lwt_unix.stdin} as input and {!Lwt_unix.stdout}
      as output. *)

val stderr : t
  (** Terminal using {!Lwt_unix.stdin} as input and {!Lwt_unix.stderr}
      as output. *)

(** {6 Low-level functions} *)

val get_size_from_fd : Lwt_unix.file_descr -> Lt_types.size Lwt.t
  (** [get_size_from_fd fd] returns the size of the terminal accessible via
      the given file descriptor. *)

val set_size_from_fd : Lwt_unix.file_descr -> Lt_types.size -> unit Lwt.t
  (** [set_size_from_fd fd size] tries to set the size of the terminal
      accessible via the given file descriptor. *)
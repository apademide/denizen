# # Fires a custom reload event, mainly listened by MODULES
# - customevent id:APADEMIDE_CORE_RELOAD

# RELOADS APADEMIDE CORE ENTIRELY
apa_core_reload:
  type: world
  debug: false
  events:
    on custom event id:APADEMIDE_CORE_RELOAD:
    - inject <script> path:RELOAD
  reload:
    # Disable APADEMIDE CORE before proceeding to checks
    - flag server APA_CORE_FLAG.INNIT:!

    # Get APADEMIDE CORE's user config script // Error and stop if null
    - define CONFIG <script[apa_core_config].if_null[NULL]>
    - if <[CONFIG]> == NULL:
      - run <script[apa_core_debug]> "context:FATAL|Cannot innit APADEMIDE CORE without the config script installed."
      - stop

    # Get APADEMIDE CORE's internal config script // Error and stop if null
    - define INTERNAL_CONFIG <script[apa_core_internal_data].if_null[NULL]>
    - if <[INTERNAL_CONFIG]> == NULL:
      - run <script[apa_core_debug]> "context:FATAL|Cannot innit APADEMIDE CORE without the *internal* config script installed."
      - stop

    # Get required config keys map from the internal config
    - define REQUIRED_CONFIG_KEYS <[INTERNAL_CONFIG].data_key[config.required].if_null[NULL]>
    - if <[REQUIRED_CONFIG_KEYS]> == NULL:
      - run <script[apa_core_debug]> "context:FATAL|The internal config script seems to be incomplete. Please update the whole APADEMIDE CORE folder to be sure everything is as it should be."
      - stop

    # Loops through every required config key to confirm they exists // Error and stop if any misses
    - foreach <[REQUIRED_CONFIG_KEYS].deep_keys> as:KEY:
      - if !<[CONFIG].data_key[<[KEY]>].exists>:
        - run <script[apa_core_debug]> "context:FATAL|The required config option in '<[CONFIG].relative_filename>' at '<[KEY].to_uppercase>' is missing."
        - stop

    # Get root flag name
    - define ROOT <[CONFIG].data_key[flags.root]>

    # Sets initial activation values
    - flag server APA_CORE_FLAG.ROOT:<[ROOT]>
    - flag server APA_CORE_FLAG.INNIT:<util.time_now>
    - flag server APA_CORE_FLAG.CONFIG:<[CONFIG]>
    - flag server APA_CORE_FLAG.LAST_RELOAD_SOURCE:<context.source.if_null[UNKNOWN]>

    # Outputs a confirmation
    - run <script[apa_core_debug]> context:INNIT
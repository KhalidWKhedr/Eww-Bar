(defwidget power []
  (eventbox :onhover "${eww} update power=true"
            :onhoverlost "${eww} update power=false"
            (box :orientation "h"
                 :space-evenly "false"
                 :vexpand "true"
                 :class "powermenu"
                 (revealer :transition "slide_down"
                           :reveal power
                           :duration "550ms"
                           (box :class "power_options"
                                :orientation "h"
                                :space-evenly "false"

                                ;; Sleep option
                                (box :class "power_option"
                                     :onclick "systemctl suspend"
                                     (button :class "sleep-icon power-icon"
                                             :height 30
                                             :width 30
                                             :valign "center"
                                             :halign "center"
                                             ""))  ;; Sleep Button         

                                ;; Hibernate option
                                (box :class "power_option"
                                     :onclick "systemctl hibernate"
                                     (button :class "hibernate-icon power-icon" 
                                             :height 30
                                             :width 30
                                             :valign "center"
                                             :halign "center"
                                             ""))  ;; Hibernate Button   

                                ;; Logout option
                                (box :class "power_option"
                                     :onclick "logout-command"
                                     (button :class "logout-icon power-icon" 
                                             :height 30
                                             :width 30
                                             :valign "center"
                                             :halign "center"
                                             ""))  ;; Logout Button

                                ;; Lock Screen option
                                (box :class "power_option"
                                     :onclick "betterlockscreen -l"
                                     (button :class "lock-icon power-icon" 
                                             :height 30
                                             :width 30
                                             :valign "center"
                                             :halign "center"
                                             ""))  ;; Lock Screen Button

                                ;; Shutdown option
                                (box :class "power_option"
                                     :onclick "shutdown now"
                                     (button :class "shutdown-icon power-icon" 
                                             :height 30
                                             :width 30
                                             :valign "center"
                                             :halign "center"
                                             ""))  ;; Shutdown Button       

                                ;; Reboot option
                                (box :class "power_option"
                                     :onclick "reboot"
                                     (button :class "reboot-icon power-icon" 
                                             :height 30
                                             :width 30
                                             "")))))))

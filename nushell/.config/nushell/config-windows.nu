# Windows-specific Nushell configuration

# Komorebi commands
def kmstart [] {
    komorebic start --whkd --bar
}

def kmstop [] {
    komorebic stop
}

def kmrestart [] {
    komorebic stop
    komorebic start --whkd --bar
}
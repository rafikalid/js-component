# SYMBOLS
COMPONENT_SYMB= Symbol 'Component'
FILE_LIST_SYMB= Symbol 'File list' # list of selected files in the input text, used with ajax
INPUT_VALIDATED= Symbol 'Field validated'


# COMPONENT_CLASS_NAME= '_core-component'
COMPONENT_NAME_REGEX= /^[^\s]+$/


# Render HTML
DIV_RENDER= document.createElement 'div'

# Event name regex
EVENT_NAME_REGEX= /^[^\s.]+$/

EVENT_LISTENER_PASSIVE_CAPTURE= {capture: yes, passive: yes}

EMAIL_REGEX=	/^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
TEL_REGEX=		/^[0+][\d\s-]{5,}$/
HEX_REGEX=		/^[\da-f]+$/i

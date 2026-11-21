#!/system/bin/sh

# Phh IMS needs these three socket-descriptor methods for binding SIP/IPsec
# sockets to the carrier IMS network. Keep the exemption limited to those APIs.
KEY=hidden_api_blacklist_exemptions
CURRENT="$(/system/bin/settings get global "$KEY" 2>/dev/null)"

for ENTRY in 'Ljava/net/ServerSocket;->getFileDescriptor$' 'Ljava/net/DatagramSocket;->getFileDescriptor$' 'Ljava/net/Socket;->getFileDescriptor$'; do
    case ",$CURRENT," in
        *,$ENTRY,*) ;;
        *)
            if [ -n "$CURRENT" ] && [ "$CURRENT" != null ]; then
                CURRENT="$CURRENT,$ENTRY"
            else
                CURRENT="$ENTRY"
            fi
            ;;
    esac
done

/system/bin/settings put global "$KEY" "$CURRENT"

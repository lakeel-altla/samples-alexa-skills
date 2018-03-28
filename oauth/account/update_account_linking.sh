#!/bin/bash
#!/usr/bin/expect -f

PROGNAME="$( basename $0 )"

PARAM=()
for opt in "$@"; do
    case "${opt}" in
        '--skill-id' )
            if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
                echo "${PROGNAME}: option requires an argument -- $( echo $2 | sed 's/^-*//' )" 1>&2
                exit 1
            fi
            SKILL_ID="$2"
            shift 2
            ;;
        '--auth-url' )
            if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
                echo "${PROGNAME}: option requires an argument -- $( echo $2 | sed 's/^-*//' )" 1>&2
                exit 1
            fi
            AUTH_URI="$2"
            shift 2
            ;;
        '--client-id' )
            if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
                echo "${PROGNAME}: option requires an argument -- $( echo $2 | sed 's/^-*//' )" 1>&2
                exit 1
            fi
            CLIENT_ID="$2"
            shift 2
            ;;
        '--scope' )
            if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
                echo "${PROGNAME}: option requires an argument -- $( echo $2 | sed 's/^-*//' )" 1>&2
                exit 1
            fi
            SCOPE="$2"
            shift 2
            ;;
        '--domain' )
            if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
                echo "${PROGNAME}: option requires an argument -- $( echo $2 | sed 's/^-*//' )" 1>&2
                exit 1
            fi
            DOMAIN="$2"
            shift 2
            ;;
        '--auth-grant-type' )
            if [[ -z "${2}" ]] || [[ "${2}" =~ ^-+ ]]; then
                echo "${PROGNAME}: option requires an argument -- $( echo ${2} | sed 's/^-*//' )" 1>&2
                exit 1
            fi
            AUTH_GRANT_TYPE="${2}"
            shift 2
            ;;
        '--access-token-uri' )
            if [[ -z "${2}" ]] || [[ "${2}" =~ ^-+ ]]; then
                echo "${PROGNAME}: option requires an argument -- $( echo ${2} | sed 's/^-*//' )" 1>&2
                exit 1
            fi
            AUTH_TOKEN_URI="${2}"
            shift 2
            ;;
        '--client-secret' )
            if [[ -z "${2}" ]] || [[ "${2}" =~ ^-+ ]]; then
                echo "${PROGNAME}: option requires an argument -- $( echo ${2} | sed 's/^-*//' )" 1>&2
                exit 1
            fi
            CLIENT_SECRET="${2}"
            shift 2
            ;;
        '--client-auth-schema' )
            if [[ -z "${2}" ]] || [[ "${2}" =~ ^-+ ]]; then
                echo "${PROGNAME}: option requires an argument -- $( echo ${2} | sed 's/^-*//' )" 1>&2
                exit 1
            fi
            CLIENT_AUTH_SCHEMA="${2}"
            shift 2
            ;;
        '--expiration' )
            # optional
            FUGA=true;
            if [[ -n "${2}" ]] && [[ ! "${2}" =~ ^-+ ]]; then
                EXPIRATION="${2}";
            fi
            ;;
        '-h' | '--help' )
            usage
            ;;
        '--' | '-' )
            shift
            PARAM+=( "$@" )
            break
            ;;
        -* )
            echo "${PROGNAME}: illegal option -- '$( echo $1 | sed 's/^-*//' )'" 1>&2
            exit 1
            ;;
        * )
            if [[ -n "$1" ]] && [[ ! "$1" =~ ^-+ ]]; then
                PARAM+=( "$1" ); shift
            fi
            ;;
    esac
done

function usage() {
  cat << EOS >&2
Usage: ${PROGNAME} [-h,--help]
[--auth-url Authorization URL]
[--client-id CLIENT ID]
[--scope SCOPE]
[--domain DOMAIN]
[--auth-grant-type AUTH GRANT TYPE]
[--access-token-uri ACCESS TOKEN URI]
[--client-secret CLIENT SECRET]
[--client-auth-schema CLIENT AUTH SCHEMA]
[--expiration EXPIRATION]

Options:
  --auth-url        Authorization URI.
  --client-id       Identifier your login page uses to recognize that the request came from your skill.
  --scope        Indicates the access that you need for the customer account such as user_id.
  --domain        A list of additional domains that your login page fetches content from.
  --auth-grant-type        Specifies the OAuth authorization grant type. Use AUTH_CODE or IMPLICIT.
  --access-token-uri        URI for requesting authorization tokens.
  --client-secret        A credential you provide that lets the Alexa service authenticate with the Access Token URI.
  --client-auth-schema        The type of authentication used such as HTTP_BASIC, or REQUEST_BODY_CREDENTIALS. Required only when AUTH_CODE is specified.
  --expiration        (Optional) The time in seconds for which access token is valid. 
  -h, --help    Show usage.
EOS
  exit 1
}

if [[ -n "${PARAM[@]}" ]]; then
    usage
fi

echo "SKILL_ID: ${SKILL_ID}"
echo "AUTH_URI: ${AUTH_URI}"
echo "CLIENT_ID: ${CLIENT_ID}"
echo "SCOPE: ${SCOPE}"
echo "DOMAIN: ${DOMAIN}"
echo "AUTH_GRANT_TYPE: ${AUTH_GRANT_TYPE}"
echo "AUTH_TOKEN_URI: ${AUTH_TOKEN_URI}"
echo "CLIENT_SECRET: ${CLIENT_SECRET}"
echo "CLIENT_AUTH_SCHEMA: ${CLIENT_AUTH_SCHEMA}"
echo "EXPIRATION: ${EXPIRATION}"

expect -c "
    spawn ask api create-account-linking -s ${SKILL_ID}
    expect \"Authorization URL:\"
    send -- \"${AUTH_URI}\n\"
    expect \"Client ID:\"
    send -- \"${CLIENT_ID}\n\"
    expect \"Scopes(separate by comma):\"
    send -- \"${SCOPE}\n\"
    expect \"Domains(separate by comma):\"
    send -- \"${DOMAIN}\n\"
    expect \"Authorization Grant Type:\"
    send -- \"${AUTH_GRANT_TYPE}\n\"
    expect \"Access Token URI:\"
    send -- \"${AUTH_TOKEN_URI}\n\"
    expect \"Client Secret:\"
    send -- \"${CLIENT_SECRET}\n\"
    expect \"Client Authentication Scheme:\"
    send -- \"${CLIENT_AUTH_SCHEMA}\n\"
    expect \"Optional* Default Access Token Expiration Time In Seconds:\"
    send -- \"${EXPIRATION}\n\"
    expect \"$\"
    exit 0
"
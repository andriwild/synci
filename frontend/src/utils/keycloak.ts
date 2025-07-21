import Keycloak, {
    KeycloakInitOptions
    } from 'keycloak-js'

const keycloak = new Keycloak({
    url: import.meta.env.VITE_KEYCLOAK_HOST,
    realm: 'synci',
    clientId: import.meta.env.VITE_CLIENT_ID_KEYCLOAK
})

const initOptions: KeycloakInitOptions = {
    onLoad: 'check-sso',
    silentCheckSsoRedirectUri: `${location.origin}/silent-check-sso.html`,
    pkceMethod: 'S256',
    checkLoginIframe: false
}

let initPromise: Promise<boolean> | null = null

export function initKeycloak() {
    if (!initPromise) {
        initPromise = keycloak.init(initOptions)
    }
    return initPromise
}

export function logout() {
    return keycloak.logout();
}

export default keycloak

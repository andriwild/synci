import {createApi} from "@reduxjs/toolkit/query/react";
import {axiosUserBaseQuery} from "../common/apiHelpers";
import {KEYCLOAK_HOST} from "../../../env.ts";

const KEYCLOAK_AUTH_URL = `${KEYCLOAK_HOST}/realms/synci/protocol/openid-connect/auth`;
const CLIENT_ID = "synci-backend";
const REDIRECT_URI = "http://localhost:8080/api/synconfig/list";
const RESPONSE_TYPE = "code";
const SCOPE = "openid";
const IDP_HINT = "google";


export const userApi = createApi({
    reducerPath: "userApi",
    baseQuery: axiosUserBaseQuery({
        baseUrl: "/realms/synci/protocol/openid-connect/auth?client_id=synci-backend&redirect_uri=http://localhost:5173/sport&response_type=code&scope=openid&kc_idp_hint=google"
    }), // Dein Backend
    endpoints: (build) => ({
        getAuthUrl: build.query<string, void>({
            query: () => ({
                url: "",
                method: "GET"
            }),
        }),
        exchangeCodeForToken: build.mutation({
            query: (authCode) => ({
                url: "/realms/synci/protocol/openid-connect/token",
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: new URLSearchParams({
                    client_id: "synci-backend",
                    client_secret: "qsRBHYpRSoqE5XrCCQE1iM6BqdK66tDK",
                    redirect_uri: "http://localhost:5173/sport",
                    grant_type: "authorization_code",
                    code: authCode,
                }),
            }),
        }),
    }),
});

export const { useGetAuthUrlQuery, useExchangeCodeForTokenMutation } = userApi;
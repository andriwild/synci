import {createApi} from "@reduxjs/toolkit/query/react";
import {axiosBaseQuery} from "../common/apiHelpers.ts";

export const userApi = createApi({
    reducerPath: "userApi",
    baseQuery: axiosBaseQuery({
        baseUrl: "/users"
    }),
    endpoints: build => ({
        /** reports email and name from the Auth0 profile; the access token itself carries neither */
        updateMe: build.mutation<number, { email?: string; name?: string }>({
            query: (profile) => ({url: "/me", method: "PUT", body: profile})
        }),
    })
});

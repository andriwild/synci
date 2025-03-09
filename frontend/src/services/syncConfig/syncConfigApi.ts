import {createApi} from "@reduxjs/toolkit/query/react";
import {axiosBaseQuery} from "../common/apiHelpers";
import {SyncConfig} from "./entities/syncConfig.ts";
import {SyncConfigRequest} from "./entities/syncConfigDto.ts";

export const syncConfigApi = createApi({
    reducerPath: "syncConfigApi",
    baseQuery: axiosBaseQuery({
        baseUrl: "/syncconfigs"
    }),
    endpoints: build => ({
        getAll: build.query<SyncConfig[], void>({
            query: () => ({
                url: "",
                method: "GET",
                headers: new Headers({
                    Authorization: `Bearer ${localStorage.getItem("token")}`
                })
            })
        }),
        create: build.mutation<SyncConfig, SyncConfigRequest>({
            query: syncConfig => ({
                url: "",
                method: "POST",
                headers: new Headers({
                    Authorization: `Bearer ${localStorage.getItem("token")}`
                }),
                body: syncConfig
            })
        }),
        update: build.mutation<SyncConfig, SyncConfigRequest>({
            query: syncConfig => ({
                url: `/${syncConfig.id}`,
                method: "PUT",
                headers: new Headers({
                    Authorization: `Bearer ${localStorage.getItem("token")}`
                }),
                body: syncConfig
            })
        }),
        delete: build.mutation<void, string>({
            query: id => ({
                url: `/${id}`,
                headers: new Headers({
                    Authorization: `Bearer ${localStorage.getItem("token")}`
                }),
                method: "DELETE"
            })
        })

})
})
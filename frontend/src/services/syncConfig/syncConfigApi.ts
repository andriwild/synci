import {createApi} from "@reduxjs/toolkit/query/react";
import {axiosBaseQuery} from "../common/apiHelpers";
import {SyncConfig} from "./entities/syncConfig.ts";
import {SyncConfigRequest} from "./entities/syncConfigDto.ts";

export const syncConfigApi = createApi({
    reducerPath: "syncConfigApi",
    baseQuery: axiosBaseQuery({
        baseUrl: "/syncconfig"
    }),
    endpoints: build => ({
        getAll: build.query<SyncConfig[], void>({
            query: () => ({
                url: "",
                method: "GET"
            })
        }),
        create: build.mutation<SyncConfig, SyncConfigRequest>({
            query: syncConfig => ({
                url: "",
                method: "POST",
                body: syncConfig
            })
        }),
        update: build.mutation<SyncConfig, SyncConfigRequest>({
            query: syncConfig => ({
                url: "{syncConfig.id}",
                method: "PUT",
                body: syncConfig
            })
        }),
        delete: build.mutation<void, string>({
            query: id => ({
                url: `/${id}`,
                method: "DELETE"
            })
        })

})
})
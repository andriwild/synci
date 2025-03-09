import {createApi} from "@reduxjs/toolkit/query/react";
import {axiosBaseQuery} from "../common/apiHelpers";
import {SyncConfig} from "./entities/syncConfig.ts";
import {SyncConfigRequest} from "./entities/syncConfigDto.ts";
import {AxiosHeaders} from "axios";

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
                headers: new AxiosHeaders({
                    Authorization: `Bearer ${localStorage.getItem("access_token")}`
                })
            })
        }),
        create: build.mutation<SyncConfig, SyncConfigRequest>({
            query: syncConfig => ({
                url: "",
                method: "POST",
                headers: new AxiosHeaders({
                    Authorization: `Bearer ${localStorage.getItem("access_token")}`
                }),
                body: syncConfig
            })
        }),
        update: build.mutation<SyncConfig, SyncConfigRequest>({
            query: syncConfig => ({
                url: `/${syncConfig.id}`,
                method: "PUT",
                headers: new AxiosHeaders({
                    Authorization: `Bearer ${localStorage.getItem("access_token")}`
                }),
                body: syncConfig
            })
        }),
        delete: build.mutation<void, string>({
            query: id => ({
                url: `/${id}`,
                headers: new AxiosHeaders({
                    Authorization: `Bearer ${localStorage.getItem("access_token")}`
                }),
                method: "DELETE"
            })
        })

})
})
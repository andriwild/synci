import {Action, configureStore, ThunkAction} from "@reduxjs/toolkit";
import {sportApi} from "../services/sport/sportApi.ts";
import {syncConfigApi} from "../services/syncConfig/syncConfigApi.ts";
import {syncConfigSliceReducer} from "../services/syncConfig/syncCofigSlice.ts";
import {userSliceReducer} from "../services/user/UserSlice.ts";
import {organisationApi} from "../services/organisation/organisationApi.ts";
import {userApi} from "../services/user/userApi.ts";
import {matchupApi} from "../services/matchup/matchupApi.ts";

export const store = configureStore({
    reducer: {
        user: userSliceReducer,
        syncConfig: syncConfigSliceReducer,
        [sportApi.reducerPath]: sportApi.reducer,
        [syncConfigApi.reducerPath]: syncConfigApi.reducer,
        [organisationApi.reducerPath]: organisationApi.reducer,
        [userApi.reducerPath]: userApi.reducer,
        [matchupApi.reducerPath]: matchupApi.reducer
    },
    middleware: getDefaultMiddleware =>
        getDefaultMiddleware()
            .concat(sportApi.middleware)
            .concat(syncConfigApi.middleware)
            .concat(organisationApi.middleware)
            .concat(userApi.middleware)
            .concat(matchupApi.middleware)
});

export type AppDispatch = typeof store.dispatch;
export type RootState = ReturnType<typeof store.getState>;
export type AppThunk<ReturnType = void> = ThunkAction<ReturnType,
    RootState,
    unknown,
    Action<string>>;

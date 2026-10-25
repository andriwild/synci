import {createApi} from "@reduxjs/toolkit/query/react";
import {axiosBaseQuery} from "../common/apiHelpers.ts";
import {EventAnswer, EventInvitation} from "../organisation/entities/organisation.ts";

type InvitationRequest = { configId: string; eventId: string };

/** The answer link in a calendar feed; works without login because the Abo id stands for its owner. */
export const invitationApi = createApi({
    reducerPath: "invitationApi",
    baseQuery: axiosBaseQuery({
        baseUrl: "/calendars"
    }),
    tagTypes: ["Invitation"],
    endpoints: build => ({
        get: build.query<EventInvitation, InvitationRequest>({
            query: ({configId, eventId}) => ({url: `/${configId}/events/${eventId}/response`, method: "GET"}),
            providesTags: ["Invitation"]
        }),
        answer: build.mutation<EventInvitation, InvitationRequest & { answer: EventAnswer }>({
            query: ({configId, eventId, answer}) => ({
                url: `/${configId}/events/${eventId}/response`,
                method: "PUT",
                body: {answer}
            }),
            invalidatesTags: ["Invitation"]
        }),
    })
});

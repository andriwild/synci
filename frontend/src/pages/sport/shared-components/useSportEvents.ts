import {useEffect, useState} from "react";
import {sportApi} from "../../../services/sport/sportApi.ts";

const PAGE_SIZE = 10;

/**
 * Events of a sport (or organisation node) with a "load more" that grows the page size.
 * A growing page instead of accumulated pages means a refetch after an edit simply replaces the list.
 */
export const useSportEvents = (sportId: string) => {
    const [limit, setLimit] = useState(PAGE_SIZE);
    useEffect(() => {
        setLimit(PAGE_SIZE);
    }, [sportId]);

    const query = sportApi.useGetEventsQuery({id: sportId, page: 0, pageSize: limit}, {skip: !sportId});
    const events = query.data?.elements ?? [];
    const amount = query.data?.amount ?? 0;

    return {
        events,
        amount,
        isLoading: query.isLoading,
        error: query.error,
        hasMore: amount > events.length,
        loadMore: () => setLimit(limit + PAGE_SIZE),
    };
};

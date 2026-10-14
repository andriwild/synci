import {Button, theme, Tooltip} from "antd";
import {IconCheck, IconPlus} from "@tabler/icons-react";
import {SubscribeBlocker} from "./useSubscription.ts";

const BLOCKER_TEXT: Record<Exclude<SubscribeBlocker, null>, string> = {
    "login": "Melde dich an, um zu abonnieren",
    "no-config": "Erstelle zuerst ein Abo",
};

/**
 * Add-to-subscription control with three visible states: addable, already subscribed
 * (green check) and blocked (disabled with the reason as tooltip).
 */
export const SubscribeButton = ({variant, included, includedVia, blocker, loading, label, onAdd}: {
    variant: "icon" | "text",
    included: boolean,
    /** set when the entry is covered by a parent subscription, e.g. the whole league */
    includedVia?: string,
    blocker: SubscribeBlocker,
    loading: boolean,
    /** accessible name, e.g. the event or team name */
    label: string,
    onAdd: () => void,
}) => {
    const token = theme.useToken().token;

    if (included || includedVia) {
        const text = includedVia ? `Über ${includedVia} abonniert` : "Bereits im Abo";
        return (
            <Tooltip title={text}>
                <span className={`subscribe-state subscribe-state--${variant}`} style={{color: token.colorSuccess}}
                      aria-label={`${label}: ${text}`}>
                    <IconCheck size={18}/>
                    {variant === "text" && <span>Im Abo</span>}
                </span>
            </Tooltip>
        );
    }

    const disabledReason = blocker ? BLOCKER_TEXT[blocker] : undefined;
    return (
        <Tooltip title={disabledReason ?? (variant === "icon" ? "Zum Abo hinzufügen" : undefined)}>
            <Button
                type={variant === "icon" ? "text" : "default"}
                size={variant === "icon" ? "middle" : "small"}
                icon={<IconPlus size={18}/>}
                disabled={!!blocker}
                loading={loading}
                aria-label={`${label} zum Abo hinzufügen`}
                onClick={onAdd}
            >
                {variant === "text" ? "Abonnieren" : null}
            </Button>
        </Tooltip>
    );
};

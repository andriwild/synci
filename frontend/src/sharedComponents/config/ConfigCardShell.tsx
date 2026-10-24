import {Button, Flex, Tag, theme, Typography} from "antd";
import {IconTrash} from "@tabler/icons-react";
import {ReactNode} from "react";
import "./ConfigCard.css";

/**
 * Common frame for the entries of a subscription (sport, team, event, organisation):
 * icon, title, optional subtitle, type tag and a remove button. Compact enough for the
 * narrow side panel on tablets and the bottom drawer on phones. [heading] replaces the plain title,
 * e.g. with the teams of a game; [title] still names the entry for screen readers.
 */
export const ConfigCardShell = ({icon, title, heading, subtitle, tag, onRemove, loading}: {
    icon: ReactNode,
    title: string,
    heading?: ReactNode,
    subtitle?: string,
    tag: string,
    onRemove: () => void,
    loading?: boolean
}) => {
    const token = theme.useToken().token;
    return (
        <div className="config-card" style={{background: token.colorBgContainer}}>
            <span className="config-card__icon">{icon}</span>
            <Flex vertical gap={4} align={"start"} className="config-card__body">
                {heading ?? <Typography.Title level={5} style={{margin: 0, width: "100%"}} ellipsis={{tooltip: title}}>{title}</Typography.Title>}
                {subtitle && <Typography.Text type={"secondary"} ellipsis style={{width: "100%"}}>{subtitle}</Typography.Text>}
                <Tag color={token.colorPrimary} style={{margin: 0}}>{tag}</Tag>
            </Flex>
            <Button
                type={"default"}
                icon={<IconTrash size={18}/>}
                aria-label={`${title} entfernen`}
                loading={loading}
                onClick={onRemove}
                className="config-card__remove"
            />
        </div>
    );
};

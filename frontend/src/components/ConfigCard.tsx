import { 
    Button, 
    Card, 
    Flex, 
    Tag,
    Typography,
} from "antd";
import { FC } from "react";
import { decodeAbbreviation } from "../model/ski";
import { Copy, Pencil, Trash } from "@phosphor-icons/react";
import { SyncConfig } from "../model/SyncConfig";
import { Api } from "../services/data";
import { useNavigate } from "react-router-dom";

const { Text } = Typography;

interface Props {
    config: SyncConfig;
    onDelete: (id: string) => void;
}

export const ConfigCard: FC<Props> = ({ config, onDelete }) => {

    const navigate = useNavigate();
    const sortedTeamNames = config.teams.map(team => team.name).sort();
    const sortedSportsNames = config.sports.map(sport => decodeAbbreviation(sport.name)).sort();

    const toClipboard = (config: SyncConfig) => {
        navigator.clipboard.writeText(Api.getSyncConfigUrl(config.id!));
        alert("Der Link wurde in die Zwischenablage kopiert")
    }


    return (
        <Card 
            key={ config.id }
            title={ config.name }
            hoverable
            style={{ width: '400px', marginBottom: 24 }}
            extra={
                <Flex justify={"end"} gap={"10px"}>
                    <Button icon={<Pencil size={'1rem'} />} onClick={ () => navigate('/config/' + config.id) }/>
                    <Button icon={<Copy size={'1rem'} />} onClick={ () => toClipboard(config) } />
                    <Button icon={<Trash size={'1rem'} />} onClick={ () => onDelete(config.id!) } />
                </Flex>
            }>
                <h2>{config.name}</h2>
                { sortedTeamNames.map(name => (<Tag key={name} color="green">{name}</Tag>)) }
                { sortedSportsNames.map(name => (<Tag key={name} color="blue">{name}</Tag>)) }
                <br/>
                <Text type="secondary">{Api.getSyncConfigUrl(config.id!)}</Text>
        </Card>
    );
};

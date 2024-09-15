import {Button, Card, Flex, List} from "antd";
import {useNavigate} from "react-router-dom";
import {Copy, Plus} from "@phosphor-icons/react";
import {useState} from "react";

interface Team {
    id: string;
    name: string;
}

export type UserConfigValues = Team;

export const UserConfig = () => {
    const navigate = useNavigate();
    const [syncing, setSyncing] = useState(false);
    const dataSource = [
        {
            id: '1',
            label: 'SuperLeague Spiele',
            teams: ['YoungBoys, Basel, Zürich, Lausanne'],
            url: 'https://google.ch',
        },
        {
            id: '2',
            label: 'Manchester Konfig',
            teams: ['Manchester United'],
            url: 'https://google.ch',
        },
        {
            id: '3',
            label: 'Manchester Konfig',
            teams: ['Manchester United'],
            url: 'https://google.ch',
        },
        {
            id: '4',
            label: 'Manchester Konfig',
            teams: ['Manchester United'],
            url: 'https://google.ch',
        },
        {
            id: '5',
            label: 'Manchester Konfig',
            teams: ['Manchester United'],
            url: 'https://google.ch',
        },
        {
            id: '6',
            label: 'Manchester Konfig',
            teams: ['Manchester United'],
            url: 'https://google.ch',
        },
    ];

    return (
        <Flex direction="column" gap={24} style={{padding: 24}} wrap={"wrap"}>
            {dataSource.map((item) => {
                return (
                    <Card key={item.id} title={item.label} extra={<Button icon={<Copy size={'1rem'} />} />} style={{minWidth: '400px', marginBottom: 24}}>
                        <List
                            size="small"
                            header={<div>Teams</div>}
                            bordered
                            dataSource={item.teams}
                            renderItem={(team) => <List.Item>{team}</List.Item>}
                        />
                    </Card>
                );
            })}
            <Card onClick={() => navigate('/config/new')} style={{minWidth: '400px', display: 'flex', justifyContent: 'center', alignItems: 'center', cursor: "pointer"}}>
           <Plus size={'2rem'} />
             </Card>

        </Flex>
    );
};

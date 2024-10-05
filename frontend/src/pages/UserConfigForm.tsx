import { 
  Button, 
  Card, 
  Flex, 
  Form, 
  Input, 
  Select
} from "antd";
import { useNavigate, useParams } from "react-router-dom";
import { useEffect, useState } from "react";
import { SyncConfig } from "../model/SyncConfig.ts";
import { useForm } from "antd/es/form/Form";
import { Team } from "../model/Team.ts";
import { Api } from "../services/data.tsx";
import { FC } from "react";


export const UserConfigForm: FC = () => {
    const navigate = useNavigate();
    const [form] = useForm();
    const {id: id} = useParams();
    const createmode = id === 'new';

    const [teams, setTeams] = useState([] as Team[]);

    useEffect(() => {
        Api.getTeams().then(setTeams);

        if (!createmode) {
            Api.getSycnConfig(id ? id : 'new')
                .then(it => {
                    const teamsLabels = it.teams.map( (team:Team) => ({value: team.id, label: team.name }));
                    form.setFieldsValue({teams: teamsLabels, name: it.name});
                })
        }
    }, []);

    const handleSubmit = (values: {teams: number[], name: string}) => {
      
        const selectedTeams = teams.filter(team => values.teams.includes(team.id));

        const syncConfig: SyncConfig = {
            id: id && id !== 'new' ? id : null,
            name: values.name,
            teams: selectedTeams
        }

        const method = createmode ? 'POST' : 'PUT';
        Api.createSyncConfig(id ? id : 'new', syncConfig,  method)
            .then(handleBack)
    };

    const handleBack = () => navigate('/config');

    return (
        <Flex vertical style={{height: '100%', width: '100%', padding: 24}}>
            <Card style={{ width: 600, textAlign: 'left' }}>

                {/*<h2 style={{ marginBottom: '20px' }}>Abonement {syncConfig.}</h2>*/}
                <p>Füge eine Konfiguration hinzu. Wähle dabei aus, für welches Team, welchen Sportler, welchen Ort oder
                welche Sportart du dich interessierst</p>

                <Form
                    form={form} 
                    onFinish={handleSubmit} 
                    layout={'vertical'} 
                    style={{marginTop: 36}}
                >

                    <Form.Item name={'name'} label={'Config Name'}>
                        <Input placeholder="Config Name" />
                    </Form.Item>

                    <Form.Item name={'teams'} label={'Teams'}>
                        <Select
                        fieldNames={{ label: "name", value: "id" }}
                        mode="multiple"
                        placeholder="Teams auswählen"
                        options={teams.map(team => ({ id: team.id, name: team.name }))}
                        style={{ width: '100%' }}
                    />
                    </Form.Item>

                    <Flex gap={'middle'} justify={'end'} style={{marginTop: 48, marginBottom: 12 }}>
                        <Button onClick={handleBack}>Zurück</Button>
                        <Button htmlType={'submit'} type={'primary'}>Submit</Button>
                    </Flex>

                </Form>
            </Card>
       </Flex>
    );
};

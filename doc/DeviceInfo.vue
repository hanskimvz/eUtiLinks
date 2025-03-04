<template>
    <form class="row g-3" id="device_info_form" >
        <div class="card col-12">
          <div class="card-header">
            <h5 class="card-title mb-0">{{ $t('device_info') }}</h5>
          </div>
          <div class="card-body row">
            <div v-for="(field, i) in fields" :key="field.key" :class="'col-' + field.col + ' mb-2'">
              <div class="form-group">
                <span v-if="field.key === '----'" class="col-form-label"></span>
                <label v-else :for="field.key" class="col-form-label">{{ $t(field.key) }}</label>
                <span v-if="field.key === 'meter_id'" :for="field.key" class="btn btn-warning btn-sm2 ms-2" @click.prevent="listSubscriber(field.value)">{{ $t('bind_subscriber') }}</span>
                <select v-if="field.type === 'select'"
                      :id="field.key"
                      v-model="field.value"
  
                      class="form-control form-control-sm"
                      :disabled="field.readonly"
  
                ><option v-for="option in field.options" :value="option.value" :key="option.value">{{ $t(option.name) }}</option>
                </select>    
                <textarea v-else-if="field.type === 'textarea'"
                      :id="field.key"
                      v-model="field.value"
                      class="form-control form-control-sm"
                      :disabled="field.readonly">
                </textarea>
                <div v-else-if="field.type === 'switch'" class="form-check form-switch bigger-switch">
                  <input 
                      class="form-check-input" 
                      type="checkbox" 
                      role="switch" 
                      :id="field.key" 
                      v-model="field.value" 
                      :readonly="field.readonly"
                  />
                </div>
                <div v-else-if="field.type === 'checkbox'" class="form-check">
                  <input 
                      class="form-check-input" 
                      type="checkbox" 
                      :id="field.key" 
                      v-model="field.value" 
                      :readonly="field.readonly"
  
                  />
                </div>
  
                <input v-else-if="field.type === 'text'"
                      :type="field.type"
                      :id="field.key"
                      v-model="field.value"
                      class="form-control form-control-sm"
                      :readonly="field.readonly" 
                />
                
              </div>
            </div>
          </div>
          <div class="card-footer d-flex">
            <span id='rs' class="text-warning col-3"></span>
            <div class="col-sm-6 text-center">
              <button @click.prevent="updateDeviceInfo" class="btn btn-primary btn-sm px-4 me-4">{{ $t('save') }}</button>
              <button @click.prevent="updateSuccess(0)" class="btn btn-secondary btn-sm px-4">{{ $t('cancel') }}</button>
            </div>
            <span class="col-3"></span>
          </div>
        </div>
    </form>
  </template>
  
  <script setup>
  import { ref, reactive, onMounted, onUnmounted, watch } from 'vue';
  import axios from 'axios';
  import { useRoute, useRouter } from 'vue-router';
  import { useI18n } from 'vue-i18n';
  import { useCookies } from 'vue3-cookies';
  
  const route = useRoute();
  const router = useRouter();
  const { cookies } = useCookies();
  const { t } = useI18n();
  
  const props = defineProps({
    device_uid: {
      type: String,
    }
  });
  const emit = defineEmits(['update', 'update:flag']);
  
  
  
  const fields = reactive([
      {key: 'device_uid',     value: '', type: 'text',    col:2, readonly: true},
      {key: 'last_access',    value: '', type: 'text',    col:2, readonly: true},
      {key: 'ref_interval',   value: '', type: 'select',  col:2, readonly: false, 
        options: [
          {name:'r1hour',   value:3600}, 
          {name:'r2hour',   value:7200}, 
          {name:'r3hour',   value:10800}, 
          {name:'r6hour',   value:21600}, 
          {name:'r12hour',  value:43200}, 
          {name:'r1day',    value:86400} 
        ]
      },
      {key: 'last_count',     value: 0, type: 'text',        col:2, readonly: true},
      {key: 'uptime',         value: 0, type: 'text',        col:2, readonly: true},
      {key: 'flag',           value: false, type: 'switch',  col:1, readonly: false},
      
      {key: 'initial_access', value: '', type: 'text',    col:2, readonly: true},
      {key: 'release_date',   value: '', type: 'text',    col:2, readonly: true},
      {key: 'install_date',   value: '', type: 'text',    col:2, readonly: true},
      {key: 'installer_id',   value: '', type: 'text',    col:2, readonly: true},
  
      {key: 'minimum',        value: '', type: 'text',    col:2, readonly: false},
      {key: 'maximum',        value: '', type: 'text',    col:2, readonly: false},
      {key: 'battery',        value: '', type: 'text',    col:2, readonly: true},
      {key: 'server_ip',      value: '', type: 'text',    col:2, readonly: false},
      {key: 'server_port',    value: '', type: 'text',    col:1, readonly: false},
      
      {key: 'last_timestamp', value: '', type: 'text',    col:2, readonly: true},
      {key: 'uptime',         value: '', type: 'text',    col:2, readonly: true},
      {key: 'initial_count',  value: '', type: 'text',    col:2, readonly: false},
      {key: 'meter_id',       value: '', type: 'text',    col:2, readonly: false},
      {key: 'error_count',    value: '', type: 'text',    col:2, readonly: true},
      {key: 'status',         value: 0,  type: 'text',    col:2, readonly: true},
      {key: '----',           value: '', type: '',        col:12, readonly: false},
      {key: 'customer_name',  value: '', type: 'text',    col:2, readonly: false},
      {key: 'customer_no',    value: '', type: 'text',    col:2, readonly: false},
      {key: 'addr_prov',      value: '', type: 'text',    col:1, readonly: false},
      {key: 'addr_city',      value: '', type: 'text',    col:1, readonly: false},
      {key: 'addr_dist',      value: '', type: 'text',    col:1, readonly: false},
      {key: 'addr_dong',      value: '', type: 'text',    col:1, readonly: false},
      {key: 'addr_detail',    value: '', type: 'text',    col:2, readonly: false},
      {key: 'share_house',    value: '', type: 'checkbox',col:1, readonly: false},
      {key: 'addr_apt',       value: '', type: 'text',    col:1, readonly: false},
      {key: 'subscriber_no',  value: '', type: 'text',    col:2, readonly: false},
      {key: 'class',          value: '', type: 'select',  col:1, readonly: false,
        options: [
          {name:'class_6',   value:'6(G4.0)'}, 
          {name:'class_4',   value:'4(G2.5)'}, 
          {name:'class_2_5',   value:'2.5(G1.6)'}, 
          {name:'class_1_6',   value:'1.6(G1.0)'}, 
          {name:'class_1_0',   value:'1.0(G0.6)'}, 
        ]
      },
  
      {key: 'in_outdoor',        value: '', type: 'select',  col:2, readonly: false,
        options: [
          {name:'outdoor',   value:'실외'}, 
          {name:'indoor',    value:'실내'}, 
        ]
      },
  
      {key: 'category',       value: '', type: 'select',  col:2, readonly: false,
        options: [
          {name:'cook_heating', value:'취사난방용'}, 
          {name:'household',     value:'주택용'}, 
          {name:'individual_heating', value:'개별난방용'}, 
        ]
  
      },
      {key: 'comment',        value: '', type: 'textarea',    col:12, readonly: false},
      
  
  
      // {key: 'group1',         value: '', type: 'text',     readonly: true},
  
      // {key: 'group2',         value: '', type: 'text',     readonly: true},
      // {key: 'group3',         value: '', type: 'text',     readonly: true},
      // {key: 'param',          value: '', type: 'text',     readonly: true},
  
  ])
  
  const post_data = reactive({});
  
  
  watch(() => [props.device_uid], ([newDeviceUid], [oldDeviceUid]) => {
    if(newDeviceUid != oldDeviceUid ){  
      // console.log('device_uid가 변경되었습니다:', newDeviceUid);
      getDeviceInfo();
    }
  });
  
  const listSubscriber = () => {
    const url = '/subscriber_list';
    const title = 'PopupWindow';
    const width = 800;
    const height = 600;
    
    const options = `
        left=0,
        top=0,
        width=${width},
        height=${height},
        location=no,
        menubar=no,
        resizable=yes,
        scrollbars=yes,
        status=no,
        toolbar=no
    `;
    // console.log(options);
    const popup = window.open(url, title, options);
  
  
    if (!popup || popup.closed || typeof popup.closed === 'undefined') {
        alert('팝업이 차단되었습니다. 팝업 차단을 해제해주세요.');
    }
  
  }
  
  const getDeviceInfo = async () => {
    document.getElementById('rs').innerHTML = t('loading_data');
  
    document.getElementById('device_info_form').style.opacity = 0.5;
    try {
      const res = await axios({
        method: 'post',
        url: '/api/query',
        data: {
          page: 'device_info',
          device_uid: props.device_uid,
          format: 'json',
          fields: [],
          db_name: cookies.get('_db_name'),
          user_id: cookies.get('_login_id'),
          role: cookies.get('_role'),
        },
      });
  
      const data = await res.data;
      console.log(data);
      if (data.code === 403) {
        router.push({ path: '/login', query: { redirect: route.path } });
        return;
      }
      if (data.data && data.data.length > 0) {
        for (let i = 0; i < fields.length; i++) {
          fields[i].value = '';
          if (data.data[0].hasOwnProperty(fields[i].key)) {
            fields[i].value = data.data[0][fields[i].key];
          }
        }
      }
      post_data['meter_id_org'] = fields.find(field => field.key === 'meter_id').value;
      
      console.log(fields);
    } catch (error) {
      console.error('Failed to fetch data', error);
    }
    document.getElementById('rs').innerHTML = '';
    document.getElementById('device_info_form').style.opacity = 1;
  }
  
  const updateDeviceInfo = () => {
    post_data['device_uid'] = props.device_uid;
    fields.forEach(field => {
      if (field.key == '----') {
        return;
      }
      if (field.readonly == false) {
        post_data[field.key] = field.value;
      }
    });
  
  
    if(post_data['ref_interval'] == null || post_data['ref_interval'] == '') {
      document.getElementById('rs').innerHTML = t('check_ref_interval');
      return;
    }
    if(post_data['server_ip'] == null || post_data['server_ip'] == '') {
      document.getElementById('rs').innerHTML = t('check_server_ip');
      return;
    }
    if(post_data['server_port'] == null || post_data['server_port'] == '' || isNaN(post_data['server_port'])) {
      document.getElementById('rs').innerHTML = t('check_server_port');
      return;
    }
    if(post_data['initial_count'] == null || post_data['initial_count'] == '' || isNaN(post_data['initial_count'])) {
      document.getElementById('rs').innerHTML = t('check_initial_count');
      return;
    }
    if(post_data['meter_id'] == null || post_data['meter_id'] == '') {
      document.getElementById('rs').innerHTML = t('check_meter_id');
      return;
    }
    console.log(post_data);
  
    updateDeviceInfoAct();
  };
  
  const updateDeviceInfoAct = async() => {
    try {
      const res = await axios({
        method: 'post',
        url: '/api/update',
        data: {
          ...post_data,
          format: 'json',
          page: 'device_info',
          db_name: cookies.get('_db_name'),
          user_id: cookies.get('_login_id'),
          role: cookies.get('_role'),
        },
      });
      const data = await res.data;
      console.log(data);
  
      if (res.status == 200) {
          updateSuccess(data.data.modified_count);
      }
    } catch (error) {
      console.error('Failed to update device info', error);
    }
  };
  
  
  const updateSuccess = (cnt) => {
    if(cnt) {
      document.getElementById('rs').innerHTML = t('update_success');
    }
    else {
      document.getElementById('rs').innerHTML = t('update_none');
    }
    setTimeout(() => {
      emit('update:flag', cnt);
    }, 2000);
    
  };
  
  onMounted(() => {
    getDeviceInfo();
    window.addEventListener('message', (event) => {
      if (event.data.type === 'DATA_FROM_CHILD') {
        console.log(event.data.data);
        Object.keys(event.data.data).forEach(key => {
          fields.forEach(field => {
            if (field.key === key) {
              field.value = event.data.data[key];
              if (key == "share_house") {
                field.value = event.data.data[key] == "O" ? true : false;
              }
            }
          });
        });
      }
    });
  });
  
  onUnmounted(() => {
    window.removeEventListener('message', (event) => {});
  });
  
  
  
  </script>
  
  <style scoped>
  
  
  input[type="text"]:read-only,
  textarea:read-only,
  select:disabled {
    background-color: #f8f9fa;  
    border-color: #dee2e6;      
    cursor: not-allowed;       
  }
  
  /* 선택적: hover 효과 제거 */
  
  input[type="text"]:read-only:hover,
  textarea:read-only:hover,
  select:disabled:hover {
    background-color: #f8f9fa;
  }
  
  
  .btn-sm2 {
    padding: 0.15rem 0.7rem 0.25rem 0.7rem;
    font-size: 0.875rem;
    line-height: 1.0;
    border-radius: 0.4rem;
  }
  
  </style>
  
  
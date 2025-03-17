<template>
  <div class="main">
    <main class="content">
      <div class="container-fluid">
        <!-- <div v-if="isViewData" class="row mb-2">
          <div class="col-12">
            <div class="card">
              <div class="card-header">
                <div class="form-label"><strong>Recv</strong></div>
                <textarea class="form-control form-control-sm" rows="3">{{ form_data.recv_org }}</textarea>                  
              </div>
              <div class="card-body">  
                <table class="table table-sm table-bordered">
                  <tr v-for="item in ['EID','UID']" :key="item">
                    <td width="100">{{ item }}</td>
                    <td>{{ form_data[item.toLowerCase()] }}</td>
                  </tr>
                  <tr>
                    <td width="100">Timestamp</td>
                    <td width="100">Counter Value</td>
                    <td>Datetime</td>
                  </tr>
                  <tr v-for="count,i in form_data.count_table" :key="i">
                    <td>{{ count[0] }}</td>
                    <td>{{ count[1] }}</td>
                    <td>{{ count[2] }}</td>
                  </tr>
                  <tr v-for="item in ['BAT','UPTIME']" :key="item">
                    <td width="100">{{ item }}</td>
                    <td>{{ form_data[item.toLowerCase()] }}</td>
                  </tr>
                </table>
              </div>
            </div>

            <div class="card mt-2">
              <div class="card-header">
                <div class="form-label"><strong>Send</strong></div>
                <textarea class="form-control form-control-sm" rows="1" v-model="form_data.send_org"></textarea>  
              </div>
              <div class="card-body">
                <table class="table table-sm table-bordered">
                  <tr v-for = "item in ['RC','SUID','TSC','TSN','CNT','MIN','MAX','SVR','PRT']" :key="item">
                    <td width="100">{{ item }}</td>
                    <td>{{ form_data[item.toLowerCase()] }}</td>
                  </tr>
                </table>
              </div>
            </div>
          </div>
        </div> -->

        <div class="row ">
          <div class="col-12">
            <div class="form-group d-flex align-items-center">
              <input type="date" id="start_date" v-model="start_date" @change="getListRecvData()" class="form-control form-control-sm me-2" style="width: 150px;" />
              <span class="me-2"> ~ </span>
              <input type="date" id="end_date" v-model="end_date" @change="getListRecvData()" class="form-control form-control-sm me-2" style="width: 150px;" />
            </div>
          </div>
        </div>
        <div class="row">
          <div class="col-12">
            <table ref="dataTableRef" class="display cell-border compact stripe hover">
                <thead>
                  <tr>
                    <th v-for="column in columns" :key="column.data">
                      {{ column.title }}
                    </th>
                  </tr>
                </thead>
            </table>
          </div>
        </div>
      </div>


      <div class="modal fade" id="myModal" tabindex="-1" aria-labelledby="modalLabel" aria-hidden="true">
        <div class="modal-dialog">
          <div class="modal-content">
            <div class="row">
              <div class="col-7">
                <div class="modal-header">
                  <strong>Recv</strong>
                </div>
                <div class="modal-body">
                  <textarea class="form-control form-control-sm" rows="5">{{ form_data.recv_org }}</textarea>     
                  <table class="table table-sm table-bordered">
                      <tr v-for="item in ['EID','UID']" :key="item">
                        <td width="100">{{ item }}</td>
                        <td>{{ form_data[item.toLowerCase()] }}</td>
                      </tr>
                      <tr>
                        <td width="100">Timestamp</td>
                        <td width="100">Counter Value</td>
                        <td>Datetime</td>
                      </tr>
                      <tr v-for="count,i in form_data.count_table" :key="i">
                        <td>{{ count[0] }}</td>
                        <td>{{ count[1] }}</td>
                        <td>{{ count[2] }}</td>
                      </tr>
                      <tr v-for="item in ['BAT','UPTIME']" :key="item">
                        <td width="100">{{ item }}</td>
                        <td>{{ form_data[item.toLowerCase()] }}</td>
                      </tr>
                    </table>
                </div>
              </div>
              <div class="col-5">
                <div class="modal-header mb-0">
                  <strong>Send</strong>
                  <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body mt-0">
                  <textarea class="form-control form-control-sm" rows="5">{{ form_data.send_org }}</textarea>     
                  <table class="table table-sm table-bordered">
                  <tr v-for = "item in ['RC','SUID','TSC','TSN','CNT','MIN','MAX','SVR','PRT']" :key="item">
                    <td width="100">{{ item }}</td>
                    <td>{{ form_data[item.toLowerCase()] }}</td>
                  </tr>
                </table>
                </div>
              </div>

            </div>
          </div>
        </div>
      </div>

    </main>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, onBeforeUnmount } from 'vue';
import axios from 'axios';
import { useI18n } from 'vue-i18n';
import { useRoute, useRouter } from 'vue-router';
import { useCookies } from 'vue3-cookies';
import { Modal } from 'bootstrap';

import DataTablesCore from 'datatables.net-bs5';
import 'datatables.net-buttons';
import 'datatables.net-buttons/js/buttons.html5.js';
import 'datatables.net-dt/js/dataTables.dataTables';

import { getDataTableOptions } from '@/components/datatable_option';
import { _tz_offset } from '@/assets/functions';

const { t } = useI18n();
const { cookies } = useCookies();
const route = useRoute();
const router = useRouter();

// const isViewData = ref(false);
const form_data = ref({});

let tz_now = new Date().getTime();
const start_date = ref(new Date(tz_now + _tz_offset*1000).toISOString().split('T')[0]);
const end_date = ref(start_date.value);

const dataTableRef = ref(null);
let dataTableInstance = null;

const columns = ref([]);
const table_head = ['datetime','eid','uid', 'ip', 'port', 'recv_len', 'recv', 'send_len', 'send'];

const initializeDataTable = (columns, data) => {
  if (dataTableRef.value) {
    const options = getDataTableOptions(t);
    options.select = false;
    dataTableInstance = new DataTablesCore(dataTableRef.value, {
      ...options,
      data,
      columns,
      select: { style: 'single' },
      pagingType: 'simple_numbers',
      autoFill: true,
    });
    dataTableInstance.on('select', function (e, dt, type, indexes) {
      const rowData = dataTableInstance.rows(indexes).data().toArray();
      if (rowData[0].eid) {
        // isViewData.value = true;
        parse_recv_data(rowData[0]);
        showModal();
      }
    });
    dataTableInstance.on('deselect', function (e, dt, type, indexes) {
      // isViewData.value = false;
    });
  }
};

const showModal = () => {
  const myModal = new Modal(document.getElementById('myModal'));
  myModal.show();
};


const parse_recv_data = (data) => {
  let i, ts, ct, dt;
  form_data.value = data;
  form_data.value.count_table = [];
  for(i=0; i<24; i++) {
    ts = parseInt('0x'+form_data.value.recv_org.slice(18+i*16, 26+i*16)) + _tz_offset;
    ct = parseInt('0x'+form_data.value.recv_org.slice(26+i*16, 34+i*16)); 
    dt = new Date(ts*1000).toISOString();
    form_data.value.count_table.push([ts, ct, dt.split('T')[0] + ' ' + dt.split('T')[1].split('.')[0]]);
  }
  form_data.value.count_table.sort((a, b) => a[0] - b[0]);

  form_data.value.bat = parseInt('0x'+form_data.value.recv_org.slice(402, 404));
  form_data.value.uptime = parseInt('0x'+form_data.value.recv_org.slice(404, 412));


  form_data.value.rc = form_data.value.send_org.slice(0, 2).toUpperCase();
  let uid_t = '';
  for(i=2; i<18; i+=2) {
    uid_t += String.fromCharCode(parseInt(form_data.value.send_org.slice(i, i+2), 16));
  }
  form_data.value.suid = uid_t.toUpperCase();
  form_data.value.tsc = parseInt('0x'+form_data.value.send_org.slice(18, 26));
  form_data.value.tsn = parseInt('0x'+form_data.value.send_org.slice(26, 34));

  dt = new Date(form_data.value.tsc*1000 + _tz_offset*1000).toISOString();
  form_data.value.tsc_dt = dt.split('T')[0] + ' ' + dt.split('T')[1].split('.')[0];
  dt = new Date(form_data.value.tsn*1000 + _tz_offset*1000).toISOString();
  form_data.value.tsn_dt = dt.split('T')[0] + ' ' + dt.split('T')[1].split('.')[0];

  form_data.value.tsc += ' (' + form_data.value.tsc_dt + ')';
  form_data.value.tsn += ' (' + form_data.value.tsn_dt + ')';
  
  form_data.value.cnt = parseInt('0x'+form_data.value.send_org.slice(34, 42));
  form_data.value.min = parseInt('0x'+form_data.value.send_org.slice(42, 46));
  form_data.value.max = parseInt('0x'+form_data.value.send_org.slice(46, 50));

  let svr_t = '';
  for(i=50; i<58; i+=2) {
    svr_t += parseInt('0x'+form_data.value.send_org.slice(i, i+2)) + '.';
  }
  form_data.value.svr = svr_t.slice(0, -1);
  form_data.value.prt = parseInt('0x'+form_data.value.send_org.slice(58, 62));

  console.log(form_data.value);


}




const getListRecvData = () => {
  console.log(start_date.value, end_date.value);
  getListRecvDataAct();
}


// Fetch data and initialize DataTable
async function getListRecvDataAct() {
  try {
    const res = await axios({
      method: 'post',
      url: '/api/query',
      data: {
        page: 'recv_data',
        daterange: [start_date.value, end_date.value + ' 23:59:59'],
        format: 'json',
        fields: [],
        db_name: cookies.get('_db_name'),
        user_id: cookies.get('_login_id'),
        role: cookies.get('_role'),
      },
      header:{"Context-Type": "multipart/form-data"}
    });

    const data = await res.data;
    console.log(data);
    if (data.code === 403) {
      router.push({ path: '/login', query: { redirect: route.path } });
      return;
    }
  
 
    const columns = table_head.map((item) => ({
      data: item,
      title: t(item),
      className: 'text-center',
    }));

    const table_body = data.data.map((row) => {
      let uid_t = '';
      for(let i=2; i<18; i+=2) {
        uid_t += String.fromCharCode(parseInt(row.recv.slice(i, i+2), 16));
      }
      row.eid = row.recv.slice(0, 2).toUpperCase();
      if (!(row.eid === 'A0' || row.eid === 'E0' || row.eid === 'E1')) {
        row.eid = '';
      }
      row.uid = uid_t.toUpperCase();
      row.recv_org = row.recv;
      row.send_org = row.send;
      if(row.recv.length > 50) {
        row.recv = row.recv.slice(0,50)+'...';
      }
      if(row.send.length > 50) {
        row.send = row.send.slice(0,50)+'...';
      }

      return row;
    });

    console.log('table_body', table_body);
 
    if (dataTableInstance) {
      dataTableInstance.destroy();
    }
    initializeDataTable(columns, table_body);
  } catch (error) {
    console.error('Failed to fetch data', error);
  }
};

onMounted(() => {
  getListRecvData();
});
onBeforeUnmount(()=>{
});
</script>


<style>
@import 'datatables.net-dt';
@import 'datatables.net-buttons-dt/css/buttons.dataTables.css';

.p-button-sm {
  font-size: 0.875rem;
  padding: 0.4rem 0.8rem;
}

.modal-dialog {
  max-width: 90%; /* 화면 너비의 90% */
  width: 90%;
  margin: 1.75rem auto;
}

.modal-content {
  min-height: 80vh; /* 화면 높이의 80% */
}

/* 반응형 크기 설정 */
@media (min-width: 992px) {
  .modal-dialog {
    max-width: 80%;
    width: 80%;
  }
}

/* 모달이 잘 보이도록 z-index 설정 */
.modal {
  z-index: 1050;
}

.modal-backdrop {
  z-index: 1040;
}
</style>

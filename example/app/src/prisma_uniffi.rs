// Code generated by Example Generator. DO NOT EDIT

use std::sync::Arc;
mod prisma;
use prisma::PrismaClient;
use tokio::runtime::Runtime;
#[derive(uniffi :: Object)]
pub struct Client {
    pub(crate) inner: Arc<PrismaClient>,
    pub(crate) runtime: Arc<Runtime>,
}
#[uniffi::export]
impl Client {
    #[uniffi::constructor]
    pub fn new() -> Arc<Self> {
        let runtime: Runtime = Runtime::new().unwrap();
        let client = runtime.block_on(async move {
            return PrismaClient::_builder().build().await.unwrap();
        });
        Self {
            inner: Arc::new(client),
            runtime: Arc::new(runtime),
        }
        .into()
    }
    pub fn db_push(&self) {
        self.runtime.block_on(async move {
            let _ = self.inner._db_push().await;
        });
    }
    pub fn db_reset(&self) {
        self.runtime.block_on(async move {
            let _ = self.inner._db_push().force_reset().await;
        });
    }
}
#[uniffi::export]
impl Client {
    pub fn create_account(&self, id: String, display_name: String) {
        let _ = self.runtime.block_on(async move {
            let data = self
                .inner
                .account()
                .create(id, display_name, vec![])
                .exec()
                .await
                .unwrap();
            return data;
        });
    }
}
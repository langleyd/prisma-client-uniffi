use prisma_client_rust_sdk::{prelude::*, prisma::dml::scalars};

#[derive(serde::Deserialize)]
struct PrismaUniffiGenerator {
    client_path: String,
}

#[derive(thiserror::Error, serde::Serialize, Debug)]
#[error("Prisma Uniffi Generator Error")]
struct Error;

impl PrismaGenerator for PrismaUniffiGenerator {
    const NAME: &'static str = "Prisma Uniffi Generator";
    const DEFAULT_OUTPUT: &'static str = "./prisma-uniffi-generator.rs";

    type Error = Error;

    fn generate(self, args: GenerateArgs) -> Result<String, Error> {
        let class_def = quote! {
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
                    let client = runtime
                        .block_on(async move {
                            return PrismaClient::_builder().build().await.unwrap();
                        });
                        Self {
                            inner: Arc::new(client),
                            runtime: Arc::new(runtime),
                        }.into()
                }

                pub fn db_push(&self) {
                    self.runtime
                    .block_on(async move {
                        let _ = self.inner._db_push().await;
                    });
                }

                pub fn db_reset(&self) {
                    self.runtime
                    .block_on(async move {
                        let _ = self.inner._db_push().force_reset().await;
                    });
                }
            }
        };

        let model_impls = args.dml.models().map(|model| {
            let create_name = format_ident!("create_{}", snake_ident(&model.name));
            let scalar_fields = model
                .scalar_fields()
                .map(|sf| snake_ident(&sf.name));
            let struct_field_params = model.scalar_fields().map(|scalar_field| {
                let field_name_snake = snake_ident(&scalar_field.name);
                let field_type = scalar_field
                    .field_type
                    .to_tokens(&quote!(super::), &scalar_field.arity);
                quote! {
                    #field_name_snake: #field_type
                }
            });

            quote! {
                #[uniffi::export]
                impl Client {
                    pub fn #create_name(
                        &self,
                        #(#struct_field_params),*
                    ) {
                        let _ = self.runtime
                        .block_on(async move {
                            let data = self
                                .inner
                                .account()
                                .create(
                                    #(#scalar_fields),*,
                                    vec![]
                                )
                                .exec()
                                .await
                                .unwrap();
                            return data;
                        });
                    }
                }
            }
        });

        Ok(quote! {
            #class_def
            #(#model_impls)*
        }
        .to_string())
    }
}

pub fn run() {
    PrismaUniffiGenerator::run();
}
